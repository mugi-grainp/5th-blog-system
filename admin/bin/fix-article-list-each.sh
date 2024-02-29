#!/bin/bash

# 初期化 ------------------------------
set -u
umask 0022
PATH='/usr/bin:/bin'
IFS=$(printf ' \t\n_'); IFS=${IFS%_}
export IFS LC_ALL=C LANG=C PATH
# -------------------------------------

if [ -e "$1/article.md" ] ; then
    :
else
    exit 0
fi

# ディレクトリ文字列を生成
date_and_directory=$(echo $1 | awk -f $(dirname $0)/fix-article-list.awk)

# 記事ファイルから日付・タイトル・要約を抽出
postdate=$(cat $1/article.md            |
          sed -n '/^---/,/^---/p'       |
          sed -n '/^postdate:/p'        |
          sed 's/^postdate: \(.*\)/\1/' |
          tr -d '\r')
title=$(cat $1/article.md      |
        sed -n '/^##/p'        |
        head -n 1              |
        sed 's/^## \(.*\)/\1/' |
        tr -d '\r')
summary=$(cat $1/article.md            |
          sed -n '/^---/,/^---/p'      |
          sed -n '/^summary:/p'        |
          sed 's/^summary: \(.*\)/\1/' |
          tr -d '\r')

# 記事Markdownファイルの投稿日時が日付情報だけだった場合は、0時丁度の時刻を付与する
postdate_fix=$(date -d ${postdate//./-} +'%Y.%m.%d %H:%M:%S')

echo -e "${postdate_fix}\t${date_and_directory}\t${title}\t${summary}"

