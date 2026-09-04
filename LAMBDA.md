# Ruby ブロック・Proc・Lambda 完全理解ガイド (Ruby Blocks, Procs & Lambdas Deep Dive)

Ruby の最大の特徴であり、美しさと柔軟性の源泉である **「ブロック（Blocks）」「Proc」「Lambda」** の完全解説書です。

Java, Python, JavaScript, C# などのエンジニアが必ず疑問に思う「ブロックと Proc と Lambda の関係」「なぜ Proc と Lambda で `return` の挙動が違うのか」「引数の厳格さ（Arity）の違い」「**`items.map(&:upcase)` の `&` 記号の正体（`to_proc`）**」まで徹底的に解説します。

---

## 📑 目次

1. [Ruby の関数型機能の 3 段階構造 (Block → Proc → Lambda)](#1-ruby-の関数型機能の-3-段階構造-block--proc--lambda)
2. [Proc vs Lambda の 2 大決定的違い ★最重要★](#2-proc-vs-lambda-の-2-大決定的違い-最重要)
3. [短縮ラムダ構文 (`->(x) { ... }`) の記法](#3-短縮ラムダ構文--x---の記法)
4. [`Symbol#to_proc` 糖衣構文 (`&:method`) の内部動作](#4-symbolto_proc-糖衣構文-method-の内部動作)
5. [カリー化 (`curry`) と部分適用](#5-カリー化-curry-と部分適用)
6. [メソッドオブジェクト (`method(:foo)`) との相互変換](#6-メソッドオブジェクト-methodfoo-との相互変換)
7. [他言語エンジニア向け比較表 (Ruby vs Python vs JavaScript vs PHP vs Rust)](#7-他言語エンジニア向け比較表-ruby-vs-python-vs-javascript-vs-php-vs-rust)
8. [理解度チェッククイズ & よくある落とし穴](#8-理解度チェッククイズ--よくある落とし穴)

---

## 1. Ruby の関数型機能の 3 段階構造 (Block → Proc → Lambda)

Ruby では、コードの塊を渡す方法が 3 段階存在します。

```
       ┌────────────────────────┐
       │  Block (ブロック構文)  │  例: do ... end / { ... } (構文でありオブジェクトではない)
       └───────────┬────────────┘
                   │ オブジェクト化 (Proc.new)
       ┌───────────▼────────────┐
       │  Proc (Proc オブジェクト)│  例: proc { |x| x * 2 } (ブロックの第一級オブジェクト化)
       └───────────┬────────────┘
                   │ より「関数」らしく制限
       ┌───────────▼────────────┐
       │  Lambda (ラムダ)       │  例: ->(x) { x * 2 } (引数検査が厳格、return がローカル)
       └────────────────────────┘
```

- **Block**: メソッド呼び出しの後ろに `{}` や `do ... end` でくっつける構文。変数に代入できない。
- **Proc**: ブロックを変数に代入したり引数として受け渡すためにオブジェクト化したもの（`Proc` クラスのインスタンス）。
- **Lambda**: `Proc` クラスのインスタンスだが、より一般的なプログラミング言語の「関数」に近い挙動をする特殊な Proc。

---

## 2. Proc vs Lambda の 2 大決定的違い ★最重要★

Proc と Lambda はどちらも `Proc` クラスのインスタンスですが、**「引数チェック（Arity）」** と **「`return` 文の脱出範囲」** の 2 点が決定的に異なります。

### ① 引数チェック (Arity Check)
- **Proc**: 引数の個数が違っても**エラーにならない**（足りない引数は `nil`、多い引数は無視）。
- **Lambda**: 引数の個数が違うと**`ArgumentError`** を投げる（通常のメソッドと同じ）。

```ruby
p = proc { |a, b| [a, b] }
l = ->(a, b) { [a, b] }

p.call(1)        #=> [1, nil] (エラーにならない！)
p.call(1, 2, 3)  #=> [1, 2]   (余剰引数は無視)

l.call(1)        #=> ❌ ArgumentError: wrong number of arguments (given 1, expected 2)
```

### ② `return` の脱出範囲 (Return Semantics)
- **Proc**: `return` すると、**「その Proc が定義された外側のメソッド」から即座にリターン**する。
- **Lambda**: `return` すると、**「その Lambda 自身」から抜けて呼び出し元に値を返す**（通常の関数と同じ）。

```ruby
def test_proc
  p = proc { return "Exited from Proc" }
  p.call
  "This line will NEVER be executed"
end

def test_lambda
  l = -> { return "Exited from Lambda" }
  l.call
  "Method finished normally"
end

puts test_proc   #=> "Exited from Proc"
puts test_lambda #=> "Method finished normally"
```

---

## 3. 短縮ラムダ構文 (`->(x) { ... }`) の記法

Ruby 1.9 から導入された `->`（Stab / Stabby lambda）により、モダンなラムダ式が簡潔に記述できます。

```ruby
# 1. 引数あり
double = ->(x) { x * 2 }
puts double.call(5) # 10
puts double.(5)     # 糖衣構文 .()
puts double[5]      # 糖衣構文 []

# 2. デフォルト引数
greet = ->(name = "World") { "Hello, #{name}!" }

# 3. 複数行ブロック
process = ->(data) do
  cleaned = data.strip
  cleaned.upcase
end
```

---

## 4. `Symbol#to_proc` 糖衣構文 (`&:method`) の内部動作

Ruby 初心者が最も魔法のように感じる構文が `words.map(&:upcase)` です。

```ruby
words = %w[apple banana cherry]

// 従来の書き方:
words.map { |w| w.upcase }

// モダンな短縮記法:
words.map(&:upcase)
```

### 🔍 裏側のメカニズム
1. メソッド引数の先頭に `&` を付けると、Ruby はそのオブジェクトの **`.to_proc` メソッドを呼び出して Proc に変換**しようとします。
2. シンボル（`:upcase`）の `to_proc` は以下のように実装されています：
   ```ruby
   class Symbol
     def to_proc
       ->(obj, *args) { obj.send(self, *args) }
     end
   end
   ```
3. その結果、各要素 `w` に対して `w.send(:upcase)` が実行されます。

---

## 5. カリー化 (`curry`) と部分適用

`Proc#curry` を使うことで、引数を小分けに受け取るカリー化関数に変換できます。

```ruby
# 3 つの引数を取る Lambda
volume = ->(w, h, d) { w * h * d }

# カリー化
curried = volume.curry

# 幅 10 の直方体ファクトリ
base_10 = curried.call(10)

# さらに高さ 5 を固定
base_10_h5 = base_10.call(5)

# 最後の奥行き 2 を与えて計算
puts base_10_h5.call(2) # 100
```

---

## 6. メソッドオブジェクト (`method(:foo)`) との相互変換

既存のクラスメソッドを第一級オブジェクトとして取り出すことができます。

```ruby
class Calculator
  def square(n)
    n * n
  end
end

calc = Calculator.new

# メソッドを Method オブジェクトとして抽出
sq_method = calc.method(:square)

# Method も call 可能
puts sq_method.call(6) # 36

# to_proc によりそのままイテレータに渡せる
puts [1, 2, 3].map(&sq_method) # [1, 4, 9]
```

---

## 7. 他言語エンジニア向け比較表 (Ruby vs Python vs JavaScript vs PHP vs Rust)

| 項目 | Ruby | Python | JavaScript (ES6) | PHP (8.1+) | Rust |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **ラムダ構文** | `->(x) { x * 2 }` | `lambda x: x*2` | `x => x * 2` | `fn($x) => $x * 2` | `\|x\| x * 2` |
| **ブロック構文** | ⭕ `do ... end` / `{}` | ❌ なし | ❌ なし | ❌ なし | ❌ なし |
| **複数行・文** | ⭕ 自由 | ❌ 式のみ | ⭕ ブロック可能 | ❌ 式のみ (アロー関数)| ⭕ 可能 |
| **外部スコープ変更** | ⭕ 自由に変更可能 | ⚠️ `nonlocal` | ⭕ 自由に変更可能 | ⭕ `use (&$var)` | ⭕ `FnMut` |
| **シンボル/メソッド参照**| ⭕ `&:upcase` | ❌ なし | ❌ なし | ⭕ `strlen(...)` | ⭕ 関数名直接 |
| **カリー化** | ⭕ `proc.curry` | `functools.partial` | 高階関数手書き | なし | なし |

---

## 8. 理解度チェッククイズ & よくある落とし穴

### Q1. 次の 2 つのコードの違いは何ですか？
```ruby
# パターン A
[1, 2, 3].each do |n|
  return if n == 2
  puts n
end

# パターン B
[1, 2, 3].each { |n| next if n == 2; puts n }
```
<details>
<summary>▶ 解答と解説</summary>

**解答**:  
- パターン A の `return` は、`each` のループを抜けるだけでなく、**`each` を呼び出している外側のメソッド全体から即座に脱出**します（その結果、1 しか出力されずメソッドが終了します）。
- パターン B の `next` は、他の言語の `continue` に相当し、現在のイテレーションをスキップして次の要素（3）に進みます（1 と 3 が出力されます）。ブロック内では「ループを抜ける」つもりで安易に `return` を書いてはいけません。
</details>

---

## まとめ

1. **「メソッドに渡すならブロック」**: 最も軽量で慣用的な Ruby の心臓部。
2. **「使い回すなら Lambda (`->`)」**: 引数チェックが厳格で、`return` も自然に振る舞う安全な第一級関数。
3. **「メソッド呼び出しをすっきり書くなら `&:method`」**: `Symbol#to_proc` による最高峰の可読性。
