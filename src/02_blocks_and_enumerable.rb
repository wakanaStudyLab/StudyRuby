# frozen_string_literal: true

# ============================================================================
# Ruby 02: ブロック・Enumerable・パターンマッチング (Blocks, Enumerable, Pattern Matching)
# ============================================================================
#
# 【他言語経験者（Rust, C#, Go, Java, Python）向け要点】
# 1. ブロック (do..end / { |x| ... }) と yield:
#    - Ruby の最も美しい抽象化。任意のメソッドに「処理の塊（クロージャ）」を渡せます。
#    - C#のラムダ式、Rustのクロージャ、Javaの関数型インターフェースを極限までシンプルにしたもの。
#
# 2. Enumerable モジュール (LINQ / Stream / Rust Iterator 相当):
#    - `.map` (変換), `.select` (フィルタ), `.reject` (除外), `.reduce` (集約)
#    - `&.method_name` (シンボルの Proc 化): `names.map(&:upcase)` は `names.map { |n| n.upcase }` の省略形。
#
# 3. パターンマッチング (case ... in - Ruby 3.0+):
#    - Rustの `match`、Pythonの `match ... case` と同様の構造的パターンマッチング。
#    - ハッシュのキー分解、配列の分割代入、ガード節 `if` をサポート。
#
# 4. ぼっち演算子 (&.) と 自己代入 (||=):
#    - `user&.address&.city`: 他言語の `?.` (オプショナルチェイニング) 相当。
#    - `config ||= default_config`: `config` が nil/false の場合のみ代入（メモ化・初期化の定番）。

module Sample
  module Control
    # 自作のブロックを受け取るタイマー関数
    def self.measure_time(label)
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "  > [#{label}] Timer started"
      result = yield # 渡されたブロックを実行
      elapsed_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000
      puts "  < [#{label}] Timer finished: #{format('%.2f', elapsed_ms)} ms"
      result
    end

    def self.evaluate_event(event)
      # Ruby 3.0+ パターンマッチング (case ... in)
      case event
      in { type: :payment, amount: a, currency: "JPY" } if a >= 100_000
        "Large JPY Payment Detected: JPY #{a.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
      in { type: :payment, amount: a, currency: curr }
        "Standard Payment: #{a} #{curr}"
      in { type: :login, user_id: uid, ip: }
        "User Login: User=#{uid}, IP=#{ip}"
      in [ :command, action, *args ]
        "Command execution: #{action} with args: #{args.inspect}"
      else
        "Unknown event format"
      end
    end

    def self.run
      puts "--- 1. Enumerable Pipeline (LINQ / Stream Equivalent) ---"
      products = [
        { name: "MacBook Pro", category: :electronics, price: 250_000, stock: 5 },
        { name: "Mechanical Keyboard", category: :electronics, price: 18_000, stock: 0 },
        { name: "Rust in Action", category: :books, price: 4_200, stock: 8 },
        { name: "Clean Code", category: :books, price: 3_800, stock: 12 },
      ]

      # 在庫あり Books のタイトルを大文字にして抽出
      available_books = products
                        .select { |p| p[:category] == :books && p[:stock].positive? }
                        .map { |p| p[:name].upcase }
      puts "Available Books: #{available_books.inspect}"

      # 在庫総額の計算 (sum / reduce)
      total_value = products.sum { |p| p[:price] * p[:stock] }
      puts "Total Inventory Value: JPY #{total_value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"

      puts "\n--- 2. Block and Yield Idiom ---"
      computed = measure_time("Heavy Sum") do
        (1..500_000).sum
      end
      puts "  Computed sum: #{computed}"

      puts "\n--- 3. Structural Pattern Matching (case ... in - Ruby 3.0+) ---"
      events = [
        { type: :payment, amount: 250_000, currency: "JPY" },
        { type: :payment, amount: 50, currency: "USD" },
        { type: :login, user_id: "usr_99", ip: "192.168.1.1" },
        [:command, :deploy, "--env=production", "--force"],
      ]

      events.each do |e|
        puts "  #{evaluate_event(e)}"
      end

      puts "\n--- 4. Safe Navigation Operator (&.) and Memoization (||=) ---"
      user = { profile: { name: "Bob" } }
      no_user = nil

      puts "User name:    #{user&.dig(:profile, :name) || 'Guest'}"
      puts "No-user name: #{no_user&.dig(:profile, :name) || 'Guest'}"

      cache = nil
      cache ||= "Initialized Value"
      puts "Memoized cache: #{cache}"
    end
  end
end

# 直接実行された場合
Sample::Control.run if __FILE__ == $PROGRAM_NAME
