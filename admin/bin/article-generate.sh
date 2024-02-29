#!/bin/bash -eu

# article-generate.sh
#
# Usage
# admin/bin/article-generate.sh article.md
#
# オプション
#     -a, --artcle-generate-only : 記事変換処理のみを行い、インデックスページ更新はしない
#
# 引数
# $1: 記事ファイル (article.md)
#
# 出力
# 記事ディレクトリに記事HTMLファイルが出力される
# 記事ディレクトリに記事Markdownファイルがコピーされる
# インデックスページが更新される

# 初期化 ----------------------------------------------------------------------
set -u
umask 0022
PATH='/usr/bin:/bin'
IFS=$(printf ' \t\n_'); IFS=${IFS%_}
export IFS LC_ALL=C LANG=C PATH

TMP_DIR=$(mktemp -d)
TMP_prefix="$TMP_DIR/${0##*/}.$$"

# インデックスページに表示する記事リンクの数
ARTICLE_COUNT=12

# 終了時は常に一時ファイルを削除する
on_exit() {
    trap 1 2 3 15
    rm -rf "${TMP_DIR}"
    exit "$1"
}
trap 'on_exit 1' 1 2 3 15

show_usage() {
    echo "Usage: $(basename "$0") [options] file..."
    echo "Options:"
    echo "    --help       このメッセージを表示する"
    echo "    --version    バージョン情報を表示する"
    echo "    -a, --article-generate-only    記事生成更新のみ実施（記事一覧更新を行わない）"
}
# -----------------------------------------------------------------------------

# コマンドライン引数処理 ------------------------------------------------------
article_generate_only_flag="no"

OPTIONS="$(getopt -n "$(basename "$0")" -o a -l article-generate-only,help,version -- "$@")"
eval set -- "$OPTIONS"
while [ $# -gt 0 ]
do
    case $1 in
        -a | --article-generate-only ) article_generate_only_flag="yes" ;;
        --help )
            echo "article-generate.sh v1.0.0"
            show_usage
            ;;
        --version )
            echo "article-generate.sh v1.0.0"
            ;;
        -- ) shift; break;;
    esac
    shift
done
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------------
# Markdownファイルの読み取り
tr -d '\r' < "$1" |
awk -v tempfileprefix="$TMP_prefix" -f "$(dirname $0)"/article-generate-main.awk |
awk -f "$(dirname $0)"/markdown-subset-translator.awk -v del_p_newline=1 > "$TMP_prefix"-honbun

# メタデータの取得
article_title=$(grep 'article_title' "$TMP_prefix"-metadata.tmp | cut -f2)
postdate_hamekomi=$(grep 'postdate' "$TMP_prefix"-metadata.tmp | cut -f2 | cut -d' ' -f1)
postdate_for_list=$(grep 'postdate' "$TMP_prefix"-metadata.tmp | cut -f2)
postdate_directory=$(echo "$postdate_hamekomi" | tr -d '.')
copyright_str=$(grep 'copyright' "$TMP_prefix"-metadata.tmp | cut -f2)
summary=$(grep 'summary' "$TMP_prefix"-metadata.tmp | cut -f2)
article_permalink=$(grep 'article_directory' "$TMP_prefix"-metadata.tmp | cut -f2)
article_keywords=$(grep 'keywords' "$TMP_prefix"-metadata.tmp | cut -f2)

# 記事ファイル配置先のパス
article_directory="$(dirname $0)/../../posts/${postdate_directory}-${article_permalink}"
article_mdfile="$article_directory/article.md"
article_htmlfile="$article_directory/index.html"

mkdir -p "$article_directory"

# はめ込み
awk -f "$(dirname $0)"/hamekomi.awk \
    -v honbun_file="$TMP_prefix-honbun" \
    -v title="${article_title}" \
    -v postdate="${postdate_hamekomi}" \
    -v copyright="${copyright_str}" \
    -v keywords="${article_keywords}" \
    "$(dirname $0)"/../templates/template.html > "$TMP_prefix"-article-html

# ファイル配置
cp "$TMP_prefix"-article-html "$article_htmlfile"
cp "$1" "$article_mdfile"
# -----------------------------------------------------------------------------------------------------------

# 記事ファイル作成のみの場合はここで終了
if [ "$article_generate_only_flag" = "yes" ]; then
    on_exit 0
fi

# -----------------------------------------------------------------------------------------------------------
# Index ページの生成
# 最新の投稿をリストに反映（先頭行に追記）
# -----------------------------------------------------------------------------------------------------------
echo -ne "${postdate_for_list}\t${postdate_directory}-${article_permalink}\t${article_title}\t${summary}\n" > "$TMP_prefix"-article-list
cat $(dirname $0)/../article-list.txt >> $TMP_prefix-article-list

# 出力処理
head -n ${ARTICLE_COUNT} $TMP_prefix-article-list > $TMP_prefix-article-newest-${ARTICLE_COUNT}

awk -f $(dirname $0)/make-index.awk \
    -v posts_list_file="$TMP_prefix-article-newest-${ARTICLE_COUNT}" \
    -v directory="${article_permalink}" \
    -v indexupdate="${postdate_hamekomi}" \
    $(dirname $0)/../templates/index-template.html       > $TMP_prefix-new-index-page

# ファイルを置き換え
mv $(dirname $0)/../article-list.txt $(dirname $0)/../article-list-prev.txt
cat $TMP_prefix-article-list > $(dirname $0)/../article-list.txt
mv $(dirname $0)/../../index.html $(dirname $0)/../../index-prev.html
mv $TMP_prefix-new-index-page $(dirname $0)/../../index.html
# -----------------------------------------------------------------------------------------------------------

# 終了処理 --------------------------------------------------------------------------------------------------
on_exit 0
# -----------------------------------------------------------------------------------------------------------
