#!/bin/bash

# rebuild-article-pages.sh
# 記事ページを再構築する
# 目的
#     記事テンプレートを更新したときの再適用
# 利用法
#     $ ./rebuild-article-pages.sh
#     引数はなし

# 初期化 ------------------------------
set -u
umask 0022
PATH='/usr/bin:/bin'
IFS=$(printf ' \t\n_'); IFS=${IFS%_}
export IFS LC_ALL=C LANG=C PATH

Tmp=/tmp/${0##*/}.$$

# 終了時は常に一時ファイルを削除する
on_exit() {
    trap 1 2 3 15
    rm -f "$Tmp-*"
    exit "$1"
}
trap 'on_exit 1' 1 2 3 15
# -------------------------------------


# -------------------------------------
# Markdownファイルに記事順に一連番号を付与する
i=1
article_dir="$(dirname $0)/../../posts"
article_dir_old="$(dirname $0)/../../posts-old"
# -------------------------------------

# -----------------------------------------------------------------------------------------------------------
# 各記事のMarkdownファイルを一時ディレクトリに集合させる
mkdir -p "$Tmp"
find "$article_dir" -name article.md |
sort                                 |
while read -r fpath ; do
    cp "$fpath" "$Tmp/article_$i.md"
    i=$((i + 1))
done
# -----------------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------------
# 元ディレクトリを退避
mv "$article_dir" "$article_dir_old"
mkdir -p "$article_dir"

# 記事リストファイルを退避
mv "$(dirname $0)"/../article-list.txt "$(dirname $0)"/../article-list-old.txt
touch "$(dirname $0)"/../article-list.txt

# トップページを退避
cp "$(dirname $0)"/../../index.html "$(dirname $0)"/../../index-old.html
cp "$(dirname $0)"/../../index-prev.html "$(dirname $0)"/../../index-prev-old.html
# -----------------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------------
# 記事再構築
find "$Tmp" -type f |
sort -t_ -k2,2n     |
while read -r fpath ; do
    "$(dirname $0)"/article-generate.sh "$fpath"
done
# -----------------------------------------------------------------------------------------------------------

# 終了処理 ----------------------------
on_exit 0
# -------------------------------------
