#!/bin/bash

# トップページに表示する最大記事件数
ARTICLE_COUNT=10

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
newest_article_postdate=$(./get-cgi-post-data postdate $Tmp-cgivars | sed 's/-/\./g')
postdate_directory=$(./get-cgi-post-data postdate $Tmp-cgivars | sed 's/-//g')
article_title=$(./get-cgi-post-data title $Tmp-cgivars)
article_directory=${postdate_directory}-$(./get-cgi-post-data directory $Tmp-cgivars)
article_summary=$(./get-cgi-post-data summary $Tmp-cgivars)

# ヘッダ出力
echo "Content-Type: text/plain; charset=UTF-8"
echo ""

# 最新の投稿をリストに反映（先頭行に追記）
echo -ne "${newest_article_postdate}\t${article_directory}\t${article_title}\t${article_summary}\n" > $Tmp-article-list
cat ../article-list.txt >> $Tmp-article-list

# 出力処理
head -n ${ARTICLE_COUNT} $Tmp-article-list > $Tmp-article-newest-${ARTICLE_COUNT}

awk -f make-index.awk \
    -v posts_list_file="$Tmp-article-newest-${ARTICLE_COUNT}" \
    -v directory="${article_directory}" \
    -v indexupdate="${newest_article_postdate}" \
    ../templates/index-template.html       > $Tmp-new-index-page

# ファイルを置き換え
mv ../article-list.txt ../article-list-prev.txt
cat $Tmp-article-list > ../article-list.txt
mv ../../index.html ../../index-prev.html
mv $Tmp-new-index-page ../../index.html

echo "Index Page Updated."

# 終了処理 ----------------------------
rm -f $Tmp-*
# -------------------------------------
