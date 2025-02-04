#!/usr/bin/awk -f

# make-rss-feed.awk
# RSS1.0フィードを生成
# 引数：ブログ記事リストファイル

BEGIN {
    # タイトル
    RSS_TITLE = "Example Blog Site"
    # リンク
    RSS_LINK = "https://blog.example.com/"
    # RSSファイルへのURL
    RSS_URL = "https://blog.example.com/blog.rss"
    # 説明
    RSS_DESCRIPTION = "ブログサイトの説明"
    # 記事URLの基礎
    ARTICLE_URL_BASE = "https://blog.example.com/posts/"

    # RSSに反映する記事数（最新からN件）
    MAX_RSS_ARTICLES = 20

    # 記事一覧
    articles[0, "dummy"] = ""
    article_count = 0

    FS = "\t"
}

# 記事一覧ファイルの読み込み
article_count < MAX_RSS_ARTICLES {
    article_count++
    articles[article_count, "postdate"] = iso8601_datetime($1)
    articles[article_count, "url"] = ARTICLE_URL_BASE $2 "/"
    articles[article_count, "title"] = $3
    articles[article_count, "description"] = $4
}

# RSSフィード出力
END {
    output_rss_feed()
}

# フィード情報出力
function output_rss_feed() {
    # RSS ヘッダ
    print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    print "<rdf:RDF xmlns=\"http://purl.org/rss/1.0/\""
    print "  xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\""
    print "  xmlns:content=\"http://purl.org/rss/1.0/modules/content/\""
    print "  xmlns:dc=\"http://purl.org/dc/elements/1.1/\""
    print "  xmlns:image=\"http://purl.org/rss/1.0/modules/image/\""
    print "  xmlns:slash=\"http://purl.org/rss/1.0/modules/slash/\""
    print "  xmlns:sy=\"http://purl.org/rss/1.0/modules/syndication/\""
    print "  xmlns:taxo=\"http://purl.org/rss/1.0/modules/taxonomy/\""
    print "  xmlns:trackback=\"http://madskills.com/public/xml/rss/module/trackback/\">"

    # チャンネル情報出力
    output_channel_info()
    # 記事情報出力
    output_article_info()
    # RSS フッタ
    print "</rdf:RDF>"
}

# チャンネル情報出力
function output_channel_info() {
    # チャンネル基本情報
    print "<channel rdf:about=\"" RSS_URL "\">"
    print "  <title>" RSS_TITLE "</title>"
    print "  <link>" RSS_LINK "</link>"
    print "  <description>" RSS_DESCRIPTION "</description>"
    print "  <items>"
    print "    <rdf:Seq>"

    # 各記事へのリンクを出力
    for (i = 1; i <= MAX_RSS_ARTICLES; i++) {
        print "      <rdf:li resource=\"" articles[i, "url"] "\" />"
    }

    # フッタ
    print "    </rdf:Seq>"
    print "  </items>"
    # RSSフィード更新日時は最新記事の日時とする
    print "  <dc:date>" articles[1, "postdate"] "</dc:date>"
    print "</channel>"
}

# 記事情報出力
function output_article_info() {
    for (i = 1; i <= MAX_RSS_ARTICLES; i++) {
        output_article_data(articles[i, "url"], articles[i, "title"],
                            articles[i, "description"], articles[i, "postdate"])
    }
}

# 記事1件分の情報出力
function output_article_data(url, title, description, postdate) {
    print "<item rdf:about=\"" url "\">"
    print "  <title>" title "</title>"
    print "  <link>" url "</link>"
    print "  <description>" description "</description>"
    print "  <dc:date>" postdate "</dc:date>"
    print "</item>"
}

# ISO 8601表現に従った日付時刻文字列を出力
# 入力：日時文字列（YYYY.MM.DD HH:MM:SS）
function iso8601_datetime(timestr) {
    element_count = split(timestr, timestr_element, /[\. :]/)

    # 要素数が3（日付だけ）の時は、時刻情報として 00:00:00を補う
    if (element_count == 3) {
        timestr_element[4] = "00"
        timestr_element[5] = "00"
        timestr_element[6] = "00"
    }
    ret = sprintf("%s-%s-%sT%s:%s:%s+09:00",
                    timestr_element[1], timestr_element[2], timestr_element[3],
                    timestr_element[4], timestr_element[5], timestr_element[6])
    return ret
}
