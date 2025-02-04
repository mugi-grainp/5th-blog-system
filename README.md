# 5th-blog-system

5代目ブログに用いているシンプルなブログ構築支援システム

## 概要

ブログ的形態を一部模倣した静的HTMLページ群を生成するシステムです。

現在のところ、各記事間の遷移リンクや月別・キーワード別分類は実装されていません。

## 利用法

### オンライン版

ファイルを丸ごとサーバに配置してください。CGIが実行可能でなければいけません。

    admin ディレクトリの名前を攻撃的アクセスされにくい、ランダム名称にすることをおすすめします。
    admin ディレクトリへのアクセスには必ず認証をかけてください。

### オフライン版

UNIX的環境で動作します。

通常の利用法は次の通りです。

    # 1. トップディレクトリで記事をMarkdown形式で書く
    # 2. 記事を生成する
    admin/bin/article-generate.sh article.md
    
    # 3. 記事一覧ファイルを更新する
    admin/bin/archive-listpage-generate.sh
    
    # 4. (試行版) RSSフィードを作成する
    ruby admin/bin/rssfeedmaker.rb admin/article-list.txt

#### 記事生成

    $ admin/bin/article-generate.sh article.md
    
    <出力>
    記事ディレクトリ (article/hogehoge) に記事HTMLファイルが出力される
    記事ディレクトリ (article/hogehoge) に記事Markdownファイルがコピーされる
    トップ (インデックス) ページが更新される
    記事インデックス (admin/article-list.txt) が更新される

オプション -a (--article-generate-only) を指定すると、記事HTML生成のみを行います。
編集・更新反映をする時に便利です。

オフライン版の記事テンプレートの説明

    ---
    postdate: 2025.02.04 22:15:30
    keywords: テスト
    copyright: Copyright(c) 2025 Foo All rights reserved.
    summary: 記事ファイルMarkdownサンプルです。
    ---
    
    # local-script-test
    
    ## 記事タイトル
    
    記事本文

- 1行目と6行目のハイフン: メタデータの区切り
- 2行目: 投稿日時（時刻部分が省略された場合は00:00:00として扱います）
- 3行目: キーワード（現バージョンでは特に意味を持ちません）
- 4行目: 著作権表記
- 5行目: 記事要約（トップページに表示されます）
- 8行目: H1 -> 記事リンクの文字列 https://www.example.net/posts/20250204-local-script-test/
- 10行目: H2 -> 記事ページのタイトル

#### 記事一覧ファイルの更新

トップページには最新記事から指定数 (article-generate.sh の ARTICLE_COUNT に指定した数) だけの記事へのリンク
が生成されます。このコマンドは、archivesディレクトリ以下に全記事のタイトル・概要・記事へのリンクの一覧HTML
を生成します。

    $ admin/bin/archive-listpage-generate.sh

    <出力>
    archives ディレクトリ以下に、全記事のタイトル・概要・記事へのリンクの一覧HTMLファイル
    (archives/index.html) が生成される。

#### 記事インデックスファイル再生成

何らかの理由で記事インデックスファイル (admin/article-list.txt) と実際の記事ディレクトリ配置に
不整合が生じることがあります。このコマンドは記事インデックスファイルを再生成します。

    $ admin/bin/fix-article-list.sh
    
    <出力>
    記事ディレクトリ配置、および各記事ディレクトリの内容に従い、記事インデックス (admin/article-list.txt)
    が更新される

#### 記事HTMLファイル・トップページの再生成

記事のテンプレートを更新したときに、そのテンプレートに従って全ページを再生成したいときに利用します。

    $ admin/bin/rebuild-article-pages.sh
    
    <出力>
    posts ディレクトリ以下の全記事について、新しいテンプレートを元に記事HTMLを再生成する
    インデックスページが更新される

#### RSSフィードの生成

Ruby版とAWK版を提供しています。

    # Ruby版
    $ ruby admin/bin/rssfeedmaker.rb admin/article-list.txt
    
    # AWK版
    $ awk -f admin/bin/make-rss-feed.awk admin/article-list.txt
    
    <出力>
    カレントディレクトリにRSSフィードのファイルが生成される。

### TODO

- [ ] 各記事間の遷移リンク
- [ ] 月別・キーワード別分類

