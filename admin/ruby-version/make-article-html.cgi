#!/usr/local/bin/ruby

require 'cgi'
require 'json'
require 'tempfile'
require 'fileutils'

cgi = CGI.new

# テンプレートファイルで初期化しておく
output = %x{ cat templates/template.html }
postdate_hamekomi  = cgi.params['postdate'][0].gsub("-", ".")
postdate_directory = cgi.params['postdate'][0].delete("\-")
directory_title    = cgi.params['directory'][0]
keywords           = cgi.params['keywords'][0]
copyright          = cgi.params['copyright'][0]
article_summary    = cgi.params['summary'][0]
article_title      = cgi.params['title'][0]


# ヘッダ出力
puts "Content-type: text/plain; charset=UTF-8\n\n"

if cgi.params['overwrite'][0] == "on"
  overwrite_flag = true
else
  overwrite_flag = false
end

# MarkdownをラフにHTMLに変換
# テンプレートファイルにはめ込み
Tempfile.create("honbun") do |honbun_f|
  Tempfile.create("article") do |f|
    honbun_f.puts cgi.params['article'][0].gsub("\r", "")
    honbun_f.puts
    honbun_f.flush

    honbun = %x{ cat "#{honbun_f.path}" | awk -f markdown-subset-translator.awk }

    f.print honbun
    f.flush

    output = %x{ awk -f hamekomi.awk \
                     -v honbun_file="#{f.path}" \
                     -v title="#{article_title}" \
                     -v postdate="#{postdate_hamekomi}" \
                     templates/template.html }

    # データ出力
    target_dir = "../posts/#{postdate_directory}-#{directory_title}"

    if !test("d", target_dir) || overwrite_flag
      FileUtils.mkdir_p(target_dir)

      # 記事HTML生成
      File.open(target_dir + "/index.html", "w") do |out_f|
        out_f.print output
      end

      # 変換前のMarkdownを同一ディレクトリに保存
      # デザイン変更時の再生成などに備える
      File.open(target_dir + "/article.md", "w") do |out_md_f|
        out_md_f.puts "---"
        out_md_f.puts "postdate: " + postdate_hamekomi
        out_md_f.puts "keywords: " + keywords
        out_md_f.puts "copyright: " + copyright
        out_md_f.puts "summary: " + article_summary
        out_md_f.puts "---"
        out_md_f.puts ""
        out_md_f.puts "# " + directory_title
        out_md_f.puts ""
        out_md_f.puts "## " + article_title
        out_md_f.puts ""
        out_md_f.puts cgi.params['article'][0].gsub("\r", "")
      end

      puts "Article Created."
    else
      puts "Article Exists - Not Overwritten."
    end
  end
end

