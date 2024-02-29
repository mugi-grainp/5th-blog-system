#!/bin/bash

# 初期化 ------------------------------
set -u
umask 0022
PATH='/usr/bin:/bin'
IFS=$(printf ' \t\n_'); IFS=${IFS%_}
export IFS LC_ALL=C LANG=C PATH

Tmp=/tmp/${0##*/}.$$
# -------------------------------------

# POST 内容読み取り
head -c ${CONTENT_LENGTH:-0} |
tr -d '\r'                   > $Tmp-cgivars

# 記事メタデータを設定
postdate_hamekomi=$(./get-cgi-post-data postdate $Tmp-cgivars | sed 's/-/\./g')
postdate_for_list="${postdate_hamekomi} $(./get-cgi-post-data posttime $Tmp-cgivars)"
postdate_directory=$(./get-cgi-post-data postdate $Tmp-cgivars | sed 's/-//g')
directory_title=$(./get-cgi-post-data directory $Tmp-cgivars)
keywords=$(./get-cgi-post-data keywords $Tmp-cgivars)
copyright=$(./get-cgi-post-data copyright $Tmp-cgivars)
article_summary=$(./get-cgi-post-data summary $Tmp-cgivars)
article_title=$(./get-cgi-post-data title $Tmp-cgivars)
overwrite=$(./get-cgi-post-data overwrite $Tmp-cgivars)
overwrite_flag=${overwrite:-"off"}

echo "Content-Type: text/plain; charset=UTF-8"
echo ""

# 記事本文を変換して保存
./get-cgi-post-data article $Tmp-cgivars |
tr -d '\r'                               |
awk -f markdown-subset-translator.awk    > $Tmp-honbun

# テンプレートにはめ込む
awk -f hamekomi.awk \
    -v honbun_file="$Tmp-honbun" \
    -v title="${article_title}" \
    -v postdate="${postdate_hamekomi}" \
    ../templates/template.html           > $Tmp-article-html

# 変換したファイルを設置
# および、記事メタデータを含むマークダウンファイルを作成
target_dir="../../posts/${postdate_directory}-${directory_title}"
if [ -d  $target_dir -a $overwrite_flag = "off" ] ; then
    echo "Article Exists - Not overwritten."
else
    mkdir -p $target_dir
    mv $Tmp-article-html $target_dir/index.html

    cat << MARKDOWNTEMPLATE > $Tmp-article-markdown
---
postdate: ${postdate_for_list}
keywords: ${keywords}
copyright: ${copyright}
summary: ${article_summary}
---

# ${directory_title}

##  ${article_title}

MARKDOWNTEMPLATE

    ./get-cgi-post-data article $Tmp-cgivars |
    tr -d '\r'                               >> $Tmp-article-markdown
    mv $Tmp-article-markdown $target_dir/article.md

    echo "Article Created."

fi

# 終了処理 ----------------------------
rm -f $Tmp-*
# -------------------------------------
