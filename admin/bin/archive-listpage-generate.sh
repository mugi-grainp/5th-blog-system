#!/bin/bash

# archive-listpage-generate.sh
#
# Usage
# admin/bin/archive-listpage-generate.sh
#
# 引数
# なし
#
# 出力
# 記事一覧ページが更新される

# 初期化 ------------------------------
set -u
umask 0022
PATH='/usr/bin:/bin'
IFS=$(printf ' \t\n_'); IFS=${IFS%_}
export IFS LC_ALL=C LANG=C PATH

Tmp=/tmp/${0##*/}.$$
# -------------------------------------

# 記事一覧を生成 -------------------------------------------------------------------------
echo "<table>" > $Tmp-articletable
echo "<tr><th>日付</th><th>タイトル</th><th>概要</th><td>" >> $Tmp-articletable

awk 'BEGIN { FS = "\t" }
     {
         split($1, datetime_str, " ")
         printf "<tr><td>%s</td><td><a href=\"posts/%s/\">%s</a></td><td>%s</td></tr>\n",
                datetime_str[1], $2, $3, $4
     }' $(dirname $0)/../article-list.txt >> $Tmp-articletable

echo "</table>" >> $Tmp-articletable
# ----------------------------------------------------------------------------------------

# テンプレートにはめ込み -----------------------------------------------------------------
cat $(dirname $0)/../templates/archives-template.html |
    sed '/@postslist/r '$Tmp'-articletable'           |
    sed '/@postslist/d'                               > $Tmp-articlehtml
# ----------------------------------------------------------------------------------------

# ファイルの置き換え ---------------------------------------------------------------------
mv $(dirname $0)/../../archives/index.html $(dirname $0)/../../archives/index-prev.html
cp $Tmp-articlehtml $(dirname $0)/../../archives/index.html
# ----------------------------------------------------------------------------------------

# 終了処理 ----------------------------
rm -f $Tmp-*
# -------------------------------------

