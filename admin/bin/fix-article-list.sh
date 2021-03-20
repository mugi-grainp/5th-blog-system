#!/bin/bash

# 初期化 ------------------------------
set -u
umask 0022
PATH='/usr/bin:/bin'
IFS=$(printf ' \t\n_'); IFS=${IFS%_}
export IFS LC_ALL=C LANG=C PATH
# -------------------------------------

# 記事ディレクトリリストを生成
find $(dirname $0)/../../posts/ -type d |
sed -e '/\.git/d' -e '/archives/d' -e '/^posts\//d' |

# メタデータ生成
xargs -IXXX bash -c "$(dirname $0)/fix-article-list-each.sh XXX" |

# 新しい順にソート（全てを引っくり返す）
tac > $(dirname $0)/../article-list.txt

