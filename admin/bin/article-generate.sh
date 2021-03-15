#!/bin/bash -eu

# article-generate.sh
#
# Usage
# admin/bin/article-generate.sh article.md
#
# 引数
# $1: 記事ファイル (article.md)
#
# 出力
# 記事ディレクトリに記事HTMLファイルが出力される
# 記事ディレクトリに記事Markdownファイルがコピーされる
# インデックスページが更新される


# 初期化 ------------------------------
set -u
umask 0022
PATH='/usr/bin:/bin'
IFS=$(printf ' \t\n_'); IFS=${IFS%_}
export IFS LC_ALL=C LANG=C PATH

Tmp=/tmp/${0##*/}.$$

ARTICLE_COUNT=10
# -------------------------------------

# -----------------------------------------------------------------------------------------------------------
# Markdownファイルの読み取り
cat $1     |
tr -d '\r' |
awk -v tempfileprefix=$Tmp -f $(dirname $0)/article-generate-main.awk |
awk -f $(dirname $0)/markdown-subset-translator.awk > $Tmp-honbun

# メタデータの取得
article_title=$(grep 'article_title' $Tmp-metadata.tmp | cut -f2)
postdate_hamekomi=$(grep 'postdate' $Tmp-metadata.tmp | cut -f2)
postdate_directory=$(echo $postdate_hamekomi | tr -d '.')
copyright_str=$(grep 'copyright' $Tmp-metadata.tmp | cut -f2)
summary=$(grep 'summary' $Tmp-metadata.tmp | cut -f2)
article_permalink=$(grep 'article_directory' $Tmp-metadata.tmp | cut -f2)
keywords=$(grep 'keywords' $Tmp-metadata.tmp | cut -f2)

# 記事ファイル配置先のパス
article_directory="$(dirname $0)/../../posts/${postdate_directory}-${article_permalink}"
article_mdfile="$article_directory/article.md"
article_htmlfile="$article_directory/index.html"

mkdir -p $article_directory

# はめ込み
awk -f $(dirname $0)/hamekomi.awk \
    -v honbun_file="$Tmp-honbun" \
    -v title="${article_title}" \
    -v postdate="${postdate_hamekomi}" \
    $(dirname $0)/../templates/template.html > $Tmp-article-html

# ファイル配置
cp $Tmp-article-html $article_htmlfile
cp $1 $article_mdfile

# -----------------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------------
# Index ページの生成
# 最新の投稿をリストに反映（先頭行に追記）
echo -ne "${postdate_hamekomi}\t${postdate_directory}-${article_permalink}\t${article_title}\t${summary}\n" > $Tmp-article-list
cat $(dirname $0)/../article-list.txt >> $Tmp-article-list

# 出力処理
head -n ${ARTICLE_COUNT} $Tmp-article-list > $Tmp-article-newest-${ARTICLE_COUNT}

awk -f $(dirname $0)/make-index.awk \
    -v posts_list_file="$Tmp-article-newest-${ARTICLE_COUNT}" \
    -v directory="${article_permalink}" \
    -v indexupdate="${postdate_hamekomi}" \
    $(dirname $0)/../templates/index-template.html       > $Tmp-new-index-page

# ファイルを置き換え
mv $(dirname $0)/../article-list.txt $(dirname $0)/../article-list-prev.txt
cat $Tmp-article-list > $(dirname $0)/../article-list.txt
mv $(dirname $0)/../../index.html $(dirname $0)/../../index-prev.html
mv $Tmp-new-index-page $(dirname $0)/../../index.html

# -----------------------------------------------------------------------------------------------------------

# 終了処理 ----------------------------
rm -f $Tmp-*
# -------------------------------------

