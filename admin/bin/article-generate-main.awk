#!/usr/bin/awk -f

# 記事生成プログラム
# 記事Markdownの変換はパーサに任せる

# 記事メタデータYAMLの処理
NR == 1 && $0 ~ /^---/ {
    getline postdate
    getline keywords
    getline copyright
    getline summary

    # YAMLのキーの部分を消す
    sub(/postdate: /, "", postdate)
    gsub(/ /, "", postdate)
    sub(/keywords: /, "", keywords)
    gsub(/ /, "", keywords)
    sub(/copyright: /, "", copyright)
    sub(/summary: /, "", summary)

    # メタデータ終わりのマークを読み飛ばす
    getline
    next
}

# 記事ディレクトリ名（MarkdownのH1扱い）の取り出し
$0 ~ /^# / {
    article_directory = $0
    sub(/# /, "", article_directory)
    next
}

# 記事タイトル（MarkdownのH2扱い）の取り出し
$0 ~ /^## / {
    article_title = $0
    sub(/## /, "", article_title)
    next
}

{
    print
}

END {
    print "postdate\t" postdate  >  tempfileprefix "-metadata.tmp"
    print "keywords\t" keywords  >> tempfileprefix "-metadata.tmp"
    print "copyright\t" copyright >> tempfileprefix "-metadata.tmp"
    print "summary\t" summary   >> tempfileprefix "-metadata.tmp"
    print "article_directory\t" article_directory >> tempfileprefix "-metadata.tmp"
    print "article_title\t" article_title >> tempfileprefix "-metadata.tmp"
}
