# Modern Bundler & Gemfile 完全理解ガイド (Bundler Master Guide)

Ruby の標準パッケージ管理システムである **「Bundler」** と設定ファイル **「Gemfile」** の完全解説書です。

「RubyGems」の依存性バージョンの競合（Dependency Hell）を解決し、**プロジェクトごとに隔離された gem 環境を構築する仕組み**、バージョン指定演算子（`~>` など）、環境別グループ、`bundle exec` の必須性、そして **`Gemfile.lock` による再現性保証** までを網羅しています。

---

## 📑 目次

1. [Bundler の基本思想とディレクトリ構成](#1-bundler-の基本思想とディレクトリ構成)
2. [Gemfile の基本構造と最重要プロパティ](#2-gemfile-の基本構造と最重要プロパティ)
3. [バージョン指定演算子完全リファレンス (`~>` の意味)](#3-バージョン指定演算子完全リファレンス--の意味)
4. [環境別グループ (`:development`, `:test`)](#4-環境別グループ-development-test)
5. [なぜ `bundle exec` を付けなければならないのか？](#5-なぜ-bundle-exec-を付けなければならないのか)
6. [実務テンプレートと CLI コマンド早見表](#6-実務テンプレートと-cli-コマンド早見表)

---

## 1. Bundler の基本思想とディレクトリ構成

```text
my_ruby_project/
├── Gemfile             # 依存ライブラリの要求仕様 (Git管理)
├── Gemfile.lock        # 実際に解決された gem の確定バージョン (Git管理)
├── .bundle/            # プロジェクトローカルの Bundler 設定 (Git除外)
└── lib/ または app/   # Ruby ソースコード
```

- **`Gemfile`**: 人間が記述する「どのような gem が必要か」のリスト。
- **`Gemfile.lock`**: Bundler が全依存の依存関係（Transitive Dependencies）を解決して確定したスナップショット。チーム全員や本番サーバーで **100% 同一の gem バージョン** が使われることを保証する。

---

## 2. Gemfile の基本構造と最重要プロパティ

```ruby
# frozen_string_literal: true

# 1. パッケージ配布元 (HTTPS 経由の公式リポジトリ)
source "https://rubygems.org"

# 2. Ruby 本体のバージョン指定 (オプションだがチーム開発で推奨)
ruby ">= 3.2.0"

# 3. 共通 gem の指定
gem "zeitwerk", "~> 2.6"        # オートローダー
gem "faraday", "~> 2.9"         # HTTP クライアント
gem "puma", "~> 6.4"            # 高速 Web サーバー

# 4. GitHub リポジトリから直接インストールする場合
# gem "custom_gem", git: "https://github.com/company/custom_gem.git", branch: "main"
```

---

## 3. バージョン指定演算子完全リファレンス (`~>` の意味)

Bundler で最も頻出する **`~>`（ペシミスティック演算子: Pessimistic Constraint）** を正しく理解することが重要です。

| 記法 | 意味 | 許可される範囲の例 |
| :--- | :--- | :--- |
| `gem "rack", "3.0.0"` | 完全一致 | `3.0.0` のみ |
| `gem "rack", ">= 3.0"` | 3.0 以上すべて | `3.0.0`, `4.0.0`, `5.0.0` |
| **`gem "rack", "~> 3.0.0"`** | **最後の桁のみ更新許可** (パッチバージョンアップ) | `>= 3.0.0` かつ `< 3.1.0` |
| **`gem "rack", "~> 3.0"`** | **マイナーバージョンアップを許可** (破壊的変更を防ぐ) | `>= 3.0` かつ `< 4.0` |

> **💡 ベストプラクティス**:  
> 通常のライブラリは **`~> 2.5`** のようにメジャーバージョン固定・マイナー更新許可で記述するのが安全です。

---

## 4. 環境別グループ (`:development`, `:test`)

本番サーバーにデプロイする際、テストツールやリンターを不要にインストールしないようグループ化します。

```ruby
# 開発環境・テスト環境のみで使用する gem
group :development, :test do
  gem "rspec", "~> 3.13"         # テスティングフレームワーク
  gem "rubocop", "~> 1.62"       # 静的解析リンター / フォーマッター
  gem "debug", ">= 1.0.0"        # 標準デバッガー
end

# 開発環境のみ
group :development do
  gem "solargraph"               # LSP (Language Server)
end
```

### 本番インストールコマンド
```bash
# 開発・テスト用 gem を除外してインストール
bundle config set --local without 'development test'
bundle install
```

---

## 5. なぜ `bundle exec` を付けなければならないのか？

システム全体に複数のバージョンの gem（例: `rubocop 1.50` と `rubocop 1.62`）がインストールされている場合、単に `rubocop` と打つと**システム側の予期せぬバージョンが起動**してしまいます。

```bash
# ❌ 避けるべき: システム標準の gem が呼ばれる可能性がある
rspec
rubocop

# ⭕ 正しい実行方法: Gemfile.lock で確定された正確な gem バージョンで実行する
bundle exec rspec
bundle exec rubocop
```

---

## 6. 実務テンプレートと CLI コマンド早見表

| コマンド | 説明 |
| :--- | :--- |
| **`bundle install`** | `Gemfile.lock` に基づいて全 gem をインストール |
| **`bundle update <gem>`** | 特定の gem（または全体）を最新版に更新し、`Gemfile.lock` を更新 |
| **`bundle exec <cmd>`** | プロジェクトの隔離された gem 環境の文脈でコマンドを実行 |
| **`bundle info <gem>`** | インストールされた特定の gem の詳細情報・パスを表示 |
| **`bundle outdated`** | 新しいバージョンがリリースされている gem の一覧を表示 |
