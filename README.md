# Modern Ruby Crash Course (For Rust, C#, Go, Java, Python, TS Developers)

Rust, C#, Go, Java, Python, TypeScript などの言語を習得済みのエンジニアが、**最短でモダン Ruby (Ruby 3.0+ / 3.2+ / 3.3+) をマスターするための実践リファレンス**です。

---

## 🚀 クイックスタート (実行方法)

### 1. Ruby のインストール (Windows)
もし Ruby が未インストールの場合は、[RubyInstaller for Windows](https://rubyinstaller.org/) からダウンロードするか、winget でインストールできます：
```powershell
winget install RubyInstallerTeam.Ruby.3.3
```

### 2. サンプルコードの実行
```powershell
# 全モジュールを一括実行
ruby main.rb

# または付属スクリプトで実行
.\run.ps1

# 各モジュールを単体実行
ruby src/01_types_and_objects.rb
ruby src/02_blocks_and_enumerable.rb
ruby src/03_oop_and_modules.rb
ruby src/04_concurrency_and_fibers.rb
```

---

## 🗺️ 言語対比マッピング早見表 (Ruby vs Rust vs C# vs Go vs Java vs Python)

| 概念・機能 | Modern Ruby (3.x) | Rust | C# | Go | Java | Python |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **すべてオブジェクト**| `1.to_s`, `nil.class` | プリミティブ分離 | プリミティブ(boxing)| プリミティブ分離 | プリミティブ(boxing)| 全てオブジェクト |
| **不変識別子** | **シンボル (`:name`)** | `&'static str` | `interned string` | `string` | `intern()` | `sys.intern()` |
| **不変データクラス** | **`Data.define`** (3.2+)| `struct` | `record` | `struct` | `record` | `@dataclass(frozen=True)` |
| **ブロック / クロージャ**| **`do..end` / `yield`** | クロージャ `\|x\|` | ラムダ `x =>` | 無名関数 | ラムダ式 | ラムダ式 / 内包表記 |
| **コレクション操作** | **`Enumerable` (map/select)**| Iterator | LINQ | slices / ループ | Stream | 内包表記 |
| **パターンマッチング** | **`case ... in`** (3.0+)| `match val` | `switch` 式 | `switch` | `switch` | `match ... case` |
| **多重継承代替** | **Module (Mix-in)** | Trait | interface デフォルト | 構造体埋め込み | interface デフォルト | 多重継承 |
| **真の並列計算 (No GIL)**| **Ractor** (3.0+) | OS スレッド / Rayon | Task / ThreadPool | goroutine | Virtual Threads | Multiprocessing |
| **安全ナビゲーション** | `&.` (ぼっち演算子) | `?` | `?.` | `if != nil` | `Optional.map` | `if obj:` |

---

## ⚠️ 他言語経験者が最もハマる Ruby の「罠」と作法

### 1. 【最大の罠】`0` や空文字 `""`、空配列 `[]` はすべて「真 (truthy)」
- Python や JavaScript、C/C++ と決定的に異なります。
- **Ruby で偽 (falsy) になるのは `false` と `nil` の 2 つだけ**です。
  ```ruby
  # ❌ 他言語の感覚で書いてはいけない
  count = 0
  if count
    puts "Runs! (0 is TRUTHY in Ruby)"
  end

  # ⭕ 正しい判定
  if count.positive?  # または count > 0
    puts "Positive count"
  end
  ```

### 2. シンボル (`:sym`) と文字列 (`"str"`) の使い分け
- 文字列はミュータブルで、同内容でも毎回メモリが割り当てられます。
- シンボルはイミュータブルで、プロセス全体で同一のアドレス（`object_id`）を共有します。
- ハッシュのキーやメソッド名・識別子には **シンボル** を使うのが業界標準です。

### 3. メソッド末尾の `!` (破壊的) と `?` (真偽値返却)
- `user.adult?`: `true` または `false` を返す述語メソッド。
- `list.sort!`: 元のオブジェクトを直接書き換える（副作用がある）破壊的メソッド。

### 4. 自己代入 (`||=`) によるメモ化
- `config ||= load_config` は、「`config` が未定義または `nil` の場合のみ代入する」という Ruby 特有の定番イディオムです。

---

## 📁 提供サンプルコードの解説

| ファイル | テーマ | 主な学習内容 |
| :--- | :--- | :--- |
| [`01_types_and_objects.rb`](./src/01_types_and_objects.rb) | **オブジェクト & Data.define** | すべてがオブジェクト, シンボル (`:sym`) vs 文字列, `Data.define` (Ruby 3.2+ 不変データ), Truthy/Falsy の規則 |
| [`02_blocks_and_enumerable.rb`](./src/02_blocks_and_enumerable.rb) | **ブロック & パターンマッチング** | `do..end`/`yield`, `Enumerable` (`map/select/sum`), シンボルのProc化 (`&:upcase`), Ruby 3.0+ `case ... in`, `&.` ぼっち演算子 |
| [`03_oop_and_modules.rb`](./src/03_oop_and_modules.rb) | **クラス & Mix-in モジュール** | `class`, `attr_reader`, `Module` の `include` (Mix-in), メタプログラミング (`send`, `method_missing`) |
| [`04_concurrency_and_fibers.rb`](./src/04_concurrency_and_fibers.rb) | **並行性 & Ractor** | `Fiber` (コルーチン), `Thread` (I/O並行), `Ractor` (Ruby 3.0+ GILフリー並列計算モデル) |
| [`05_blocks_procs_and_lambdas.rb`](./src/05_blocks_procs_and_lambdas.rb) | **ブロック・Proc・Lambda** | Proc vs Lambda の引数検査 (Arity) と `return` 挙動の違い, `&:method` 糖衣構文, カリー化 (`curry`) |
| [`main.rb`](./main.rb) | **統合エントリーポイント** | 全モジュールを一括実行するランナー |

> 📖 **Ruby ブロック・Proc・Lambda 完全理解ガイド**:
> Block と Proc と Lambda の 3 段階構造、`return` の脱出範囲の違い、`words.map(&:upcase)` の `&` 記号の正体（`to_proc`）、カリー化・部分適用まで完全網羅した解説は [**`LAMBDA.md`**](./LAMBDA.md) を参照してください。

> 🛠️ **Modern Bundler & Gemfile 完全理解ガイド**:
> Gemfile の書き方、ペシミスティック演算子 `~>` の意味、環境別グループ (`:development, :test`)、`bundle exec` の必須性、`Gemfile.lock` による再現性保証まで完全網羅した解説は [**`BUNDLER_GUIDE.md`**](./BUNDLER_GUIDE.md) を参照してください。

---

## ⚙️ VS Code での Ruby 開発設定ガイド (`launch.json` & `settings.json`)

### 1. `launch.json` の書き方 (デバッグ起動設定)

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            // ① 【デフォルト】現在アクティブに開いているタブの Ruby スクリプトを単体実行
            "name": "▶ Ruby: Current File",
            "type": "ruby_lsp",
            "request": "launch",
            "program": "${file}",
            "cwd": "${fileDirname}"
        },
        {
            // ② 統合ランナー (main.rb) を実行して全モジュールを一括検証
            "name": "▶ Ruby: Run main.rb (All Modules)",
            "type": "ruby_lsp",
            "request": "launch",
            "program": "${workspaceFolder}/main.rb",
            "cwd": "${workspaceFolder}"
        }
    ]
}
```

### 2. `settings.json` の書き方 (ワークスペース設定)

```json
{
    "files.encoding": "utf8",
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true
}
```
