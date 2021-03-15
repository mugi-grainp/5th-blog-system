#!/usr/bin/awk -f

# 外部変数からの入力
#     posts_list_file: 投稿一覧ファイル
#     indexupdate: トップページ更新日を表す文字列

{
    if ($0 ~ /@posts/) {
        while ((getline line < posts_list_file) > 0) {
            split(line, row, "\t")
            print output_article_parts(row)
        }
        close(posts_list_file)
    } else if ($0 ~ /@indexupdate/) {
        gsub("@indexupdate", indexupdate, $0)
        print
    } else {
        print
    }
}

function output_article_parts(data) {
    print "<article>"
    print "    <h3><a href=\"posts/" data[2] "/\">" data[3] "</a></h3>"
    print "    <p>投稿日: " data[1] "</p>"
    print "    <p>" data[4] "</p>"
    print "</article>"
}
