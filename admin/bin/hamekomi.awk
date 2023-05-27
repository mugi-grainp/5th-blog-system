#!/usr/bin/awk -f

# 外部変数からの入力
#     honbun_file: 本文に関する一時ファイル
#     title: タイトル文字列
#     postdate: 投稿日を示す文字列
#     copyright: 著作権表示を示す文字列
#     keywords: 記事につけられたタグ（キーワード）

$0 ~ /@honbun/ {
    while ((getline line < honbun_file) > 0)
        print line
    close(honbun_file)
    next
}

$0 ~ /@title/ {
    gsub("@title", title, $0)
}

$0 ~ /@postdate/ {
    gsub("@postdate", postdate, $0)
}

$0 ~ /@copyright/ {
    gsub("@copyright", copyright, $0)
}

$0 ~ /@keywords/ {
    keyword_str = ""
    split(keywords, keyword_array, ",")

    for (kw in keyword_array) {
        url_str = "keywords/" keyword_array[kw] ".html"
        keyword_str = keyword_str ", <a href=\"" url_str "\">" keyword_array[kw] "</a>"
    }
    sub(", ", "", keyword_str)

    gsub("@keywords", keyword_str, $0)
}

{
    print
}

# {
#     if ($0 ~ /@honbun/) {
#         while ((getline line < honbun_file) > 0)
#             print line
#         close(honbun_file)
#     } else if ($0 ~ /@title/) {
#         gsub("@title", title, $0)
#         print
#     } else if ($0 ~ /@postdate/) {
#         gsub("@postdate", postdate, $0)
#         print
#     } else if ($0 ~ /@copyright/) {
#         gsub("@copyright", copyright, $0)
#         print
#     } else if ($0 ~ /@keywords/) {
#         keyword_str = ""
#         print "DEBUG: keyword = " keywords > "/dev/stderr"
#         split(keywords, keyword_array, ",")
# 
#         for (kw in keyword_array) {
#             url_str = "keywords/" keyword_array[kw] ".html"
#             keyword_str = keyword_str ", <a href=\"" url_str "\">" keyword_array[kw] "</a>"
#         }
#         sub(", ", "", keyword_str)
# 
#         gsub("@keywords", keyword_str, $0)
#         print
#     } else {
#         print
#     }
# }
