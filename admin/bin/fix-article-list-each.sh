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

# 日付文字列・ディレクトリ文字列を生成
date_and_directory=$(echo $1 | awk -f $(dirname $0)/fix-article-list.awk)

# 記事ファイルからタイトルと要約を抽出
title=$(cat $1/article.md      |
        sed -n '/^##/p'        |
        sed 's/^## \(.*\)/\1/' |
        tr -d '\r')
summary=$(cat $1/article.md            |
          sed -n '/^---/,/^---/p'      |
          sed -n '/^summary:/p'        |
          sed 's/^summary: \(.*\)/\1/' |
          tr -d '\r')

echo -e "$date_and_directory\t$title\t$summary"

