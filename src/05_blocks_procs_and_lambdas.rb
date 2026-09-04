# frozen_string_literal: true

module Sample
  module Closures
    # ==========================================================================
    # モジュール 05: ブロック・Proc・Lambda (Blocks, Procs & Lambdas)
    # ==========================================================================
    #
    # 【他言語経験者向け要点】
    # 1. Ruby の無名関数の3段階:
    #    - Block: メソッドに直接渡す構文（第一級オブジェクトではない）。
    #    - Proc: ブロックをオブジェクト化したもの (`Proc.new { ... }`)。
    #    - Lambda: より通常の「関数」に近い Proc (`->(x) { ... }` または `lambda { ... }`)。
    #
    # 2. Proc と Lambda の決定的な2大違い:
    #    - ① 引数チェック (Arity):
    #      Proc は引数の数が違っても無視する（不足は nil、超過は破棄）。
    #      Lambda は引数の数が違うと ArgumentError を発生させる。
    #    - ② return の挙動:
    #      Proc 内の return は「Proc が定義された外側のメソッド」から即脱出する。
    #      Lambda 内の return は「その Lambda 自身」から抜けて呼び出し元に値を返す。
    #
    # 3. Symbol#to_proc 糖衣構文 (&:method):
    #    - `words.map(&:upcase)` は `words.map { |w| w.upcase }` と等価。
    #
    # 4. カリー化 (Currying):
    #    - `add.curry` により部分適用（Partial Application）が可能。
    def self.run
      demo_proc_vs_lambda_arity
      demo_proc_vs_lambda_return
      demo_symbol_to_proc
      demo_currying_and_closures
    end

    def self.demo_proc_vs_lambda_arity
      puts "--- 1. Arity Check: Proc (Flexible) vs Lambda (Strict) ---"

      my_proc = proc { |a, b| "Proc received: a=#{a.inspect}, b=#{b.inspect}" }
      my_lambda = ->(a, b) { "Lambda received: a=#{a.inspect}, b=#{b.inspect}" }

      # Proc は引数が足りなくてもエラーにならず nil が代入される
      puts "  " + my_proc.call(10)
      puts "  " + my_proc.call(10, 20, 30) # 余剰引数も無視

      # Lambda は通常の関数と同様に引数チェックが厳格
      puts "  " + my_lambda.call(10, 20)
      begin
        my_lambda.call(10)
      rescue ArgumentError => e
        puts "  [Expected Lambda Error]: #{e.message}"
      end
    end

    def self.demo_proc_vs_lambda_return
      puts "\n--- 2. Return Semantics: Proc (Method Return) vs Lambda (Local Return) ---"

      puts "  Calling with Lambda: " + run_with_lambda
      puts "  Calling with Proc:   " + run_with_proc
    end

    def self.run_with_lambda
      l = -> { return "Returned from Lambda" }
      l.call
      "Method finished normally (Lambda did not exit outer method)"
    end

    def self.run_with_proc
      p = proc { return "Exited method immediately via Proc return!" }
      p.call
      "This line will NEVER be reached!"
    end

    def self.demo_symbol_to_proc
      puts "\n--- 3. Symbol#to_proc (&:method) Idiom ---"

      words = %w[ruby rust crystal elixir]

      # 通常のブロック
      # words.map { |w| w.capitalize }
      # Symbol#to_proc による短縮記法
      capitalized = words.map(&:capitalize)
      lengths = words.map(&:length)

      puts "  Capitalized: #{capitalized.inspect}"
      puts "  Lengths:     #{lengths.inspect}"
    end

    def self.demo_currying_and_closures
      puts "\n--- 4. Closures & Currying (Partial Application) ---"

      # 状態を持つクロージャ (環境変数のキャプチャ)
      multiplier = 5
      scale = ->(n) { n * multiplier }
      puts "  Scale 10 by #{multiplier}: #{scale.call(10)}"

      # カリー化による部分適用
      volume = ->(w, h, d) { w * h * d }
      curried_vol = volume.curry

      # 幅 10 の直方体計算関数を作る
      vol_with_w10 = curried_vol.call(10)
      # さらに高さ 5 を固定
      vol_with_w10_h5 = vol_with_w10.call(5)

      puts "  Curried Volume (10 x 5 x 2): #{vol_with_w10_h5.call(2)}"
    end
  end
end

Sample::Closures.run if __FILE__ == $PROGRAM_NAME
