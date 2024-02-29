#!/usr/bin/env ruby

# rssfeedmaker.rb
# RSSフィードを作成する

require 'rss'
require 'time'

# 記事リストファイル
list_fname = ARGV.shift

# 記事リスト
article_list = []

# 各記事を示す構造体
Article = Struct.new(:title, :pubdate, :description, :link)

# 記事URLの基礎
ARTICLE_URL_BASE = "https://blog.example.com/posts/"

# RSSに反映する記事数（最新からN件）
rss_articles = 20

# 記事情報一覧を読み込む
File.open(list_fname) do |f_input|
  count = 0
  f_input.each do |line|
    break if count >= rss_articles

    elem = line.split("\t")
    article_url = ARTICLE_URL_BASE + elem[1] + "/"
    article = Article.new(elem[2], Time.parse(elem[0]), elem[3], article_url)
    article_list << article

    count += 1
  end
end

rss = RSS::Maker.make("1.0") do |maker|
  # サイトに関する基礎情報
  maker.channel.about = "https://blog.example.com/blog.rss"
  maker.channel.title = "Example Blog Site"
  maker.channel.description = "ブログサイトの説明"
  maker.channel.link = "https://blog.example.com/"
  maker.channel.author = "foo"

  # フィード更新日時はプログラム実行日とする
  maker.channel.date = Time.now

  # 各記事の情報を作成する
  article_list.each do |article|
    maker.items.new_item do |item|
      item.title = article.title
      item.date = article.pubdate
      item.description = article.description
      item.link = article.link
    end
  end
end

File.open("blog.rss", "w:utf-8") do |f|
  f.puts rss.to_s
end
