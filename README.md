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

    $ admin/bin/article-generate.sh article.md
    
    <出力>
    記事ディレクトリ (article/hogehoge) に記事HTMLファイルが出力される
    記事ディレクトリ (article/hogehoge) に記事Markdownファイルがコピーされる
    トップ (インデックス) ページが更新される
    記事インデックス (admin/article-list.txt) が更新される

オフライン版の記事テンプレートの説明

    ---
    postdate: 2021.03.16
    keywords: テスト
    copyright: Copyright(c) 2020-2021 foobar All rights reserved.
    summary: ローカル側スクリプトのテスト
    ---
    
    # local-script-test
    
    ## 記事タイトル
    
    記事本文

- 1行目と6行目のハイフン: メタデータの区切り
- 2行目: 投稿日
- 3行目: キーワード（現バージョンでは特に意味を持ちません）
- 4行目: 著作権表記
- 5行目: 記事要約（トップページに表示されます）
- 8行目: H1 -> 記事リンクの文字列 https://www.example.net/posts/20210316-local-script-test/
- 10行目: H2 -> 記事ページのタイトル

### TODO

- 各記事間の遷移リンク
- 月別・キーワード別分類
- MarkdownファイルからのHTML再構築
- 記事インデックスファイル等が壊れた場合の再生成
