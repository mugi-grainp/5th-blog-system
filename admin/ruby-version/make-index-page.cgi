#!/usr/local/bin/ruby

require 'cgi'
require 'json'
require 'tempfile'
require 'fileutils'

# トップページに表示する最大記事件数
ARTICLE_COUNT = 10

cgi = CGI.new

# テンプレートファイルで初期化しておく
output = %x{ cat templates/index-template.html }
newest_article_postdate = cgi.params['postdate'][0].gsub("-", ".")
postdate_directory      = cgi.params['postdate'][0].delete("\-")
article_title           = cgi.params['title'][0]
article_directory       = postdate_directory + "-" + cgi.params['directory'][0]
article_summary         = cgi.params['summary'][0]

# ヘッダ出力
puts "Content-type: text/plain; charset=UTF-8\n\n"

# 最新の投稿をリストに反映
File.open("article-list-new.txt", "w") do |new_f|
  new_f.puts "#{newest_article_postdate}\t#{article_directory}\t#{article_title}\t#{article_summary}"
  File.open("article-list.txt") do |old_f|
    old_f.each_line do |line|
      new_f.puts line
    end
  end
end

# 出力処理
Tempfile.create("article-list") do |f|
  article_list = %x{ head -#{ARTICLE_COUNT} article-list-new.txt }
  f.print article_list
  f.flush

  output = %x{ awk -f make-index.awk \
                   -v posts_list_file="#{f.path}" \
                   -v directory="#{article_directory}" \
                   -v indexupdate="#{newest_article_postdate}" \
                   templates/index-template.html }

  File.open("../index-next.html", "w") do |out_f|
    out_f.print output
  end
end

# ファイルを置き換え
FileUtils.rm("article-list.txt")
FileUtils.mv("article-list-new.txt", "article-list.txt")
FileUtils.mv("../index.html", "../index-prev.html")
FileUtils.mv("../index-next.html", "../index.html")

puts "Index Page Updated."

