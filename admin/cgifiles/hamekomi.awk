#!/usr/bin/awk -f

# 外部変数からの入力
#     honbun_file: 本文に関する一時ファイル
#     title: タイトル文字列
#     postdate: 投稿日を示す文字列

{
    if ($0 ~ /@honbun/) {
        while ((getline line < honbun_file) > 0)
            print line
        close(honbun_file)
    } else if ($0 ~ /@title/) {
        gsub("@title", title, $0)
        print
    } else if ($0 ~ /@postdate/) {
        gsub("@postdate", postdate, $0)
        print
    } else {
        print
    }
}
