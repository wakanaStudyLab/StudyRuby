# frozen_string_literal: true

# ============================================================================
# Ruby 03: オブジェクト指向・モジュール (Mix-in)・メタプログラミング (OOP & Modules)
# ============================================================================
#
# 【他言語経験者（Rust, C#, Go, Java, Python）向け要点】
# 1. モジュールと Mix-in (多重継承の代替):
#    - Ruby は単一継承ですが、`Module` を定義して `include` することで
#      いくらでも機能（メソッド群）を注入できます（Rust の Trait / PHP の Trait 相当）。
#    - `include`: インスタンスメソッドとして注入。
#    - `extend`: クラスメソッド（static）として注入。
#    - `prepend`: 既存メソッドをオーバーライドして前後にフック処理を挟む（AOP 相当）。
#
# 2. attr_reader / attr_writer / attr_accessor:
#    - インスタンス変数 `@var` の getter / setter を自動生成するマクロ（C#の自動プロパティ相当）。
#
# 3. メタプログラミング (Metaprogramming):
#    - `send(:method_name, *args)`: 文字列やシンボルで動的にメソッドを呼び出す。
#    - `respond_to?(:method_name)`: メソッドが存在するか判定。
#    - `method_missing`: 未定義メソッド呼び出しをインターセプト（ActiveRecord などの基盤技術）。

module Sample
  module OOP
    # ========================================================================
    # 1. Mix-in 用モジュールの定義
    # ========================================================================
    module Loggable
      def log(message)
        puts "  [LOG #{Time.now.strftime('%H:%M:%S')}] #{message}"
      end
    end

    # ========================================================================
    # 2. クラス定義とモジュールの include
    # ========================================================================
    class BankAccount
      include Loggable # Mix-in によるメソッド注入

      attr_reader :account_number, :balance # 自動 getter

      def initialize(account_number, initial_balance = 0.0)
        @account_number = account_number
        @balance = [0.0, initial_balance].max
        log("Account #{@account_number} created with balance JPY #{@balance.to_i}")
      end

      def deposit(amount)
        raise ArgumentError, "Deposit amount must be positive" if amount <= 0

        @balance += amount
        log("Deposited JPY #{amount.to_i} -> New Balance: JPY #{@balance.to_i}")
      end

      def withdraw(amount)
        raise ArgumentError, "Withdrawal amount must be positive" if amount <= 0
        raise "Insufficient funds" if @balance < amount

        @balance -= amount
        log("Withdrew JPY #{amount.to_i} -> Remaining: JPY #{@balance.to_i}")
      end
    end

    # ========================================================================
    # 3. メタプログラミング: 動的ディスパッチと method_missing
    # ========================================================================
    class DynamicQueryBuilder
      def initialize
        @conditions = {}
      end

      # find_by_name("Alice") や find_by_role("admin") などの未定義メソッドを動的解決
      def method_missing(method_name, *args, &block)
        if method_name.to_s.start_with?("find_by_")
          column = method_name.to_s.delete_prefix("find_by_")
          "SELECT * FROM records WHERE #{column} = '#{args.first}'"
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name.to_s.start_with?("find_by_") || super
      end
    end

    def self.run
      puts "--- 1. Object-Oriented Mix-in with Modules ---"
      account = BankAccount.new("AC-9988", 50_000.0)
      account.deposit(20_000.0)
      account.withdraw(15_000.0)
      puts "Final Account Balance: JPY #{account.balance.to_i}"

      puts "\n--- 2. Metaprogramming & Dynamic Dispatch (send / respond_to?) ---"
      # シンボル経由で動的にメソッドを呼び出す (C# リフレクションや Go reflect より遥かに手軽)
      method_to_call = :balance
      if account.respond_to?(method_to_call)
        result = account.send(method_to_call)
        puts "Dynamically invoked .balance -> JPY #{result.to_i}"
      end

      puts "\n--- 3. Dynamic Method Interception (method_missing) ---"
      builder = DynamicQueryBuilder.new
      puts "Generated SQL 1: #{builder.find_by_email('alice@example.com')}"
      puts "Generated SQL 2: #{builder.find_by_status('active')}"
    end
  end
end

# 直接実行された場合
Sample::OOP.run if __FILE__ == $PROGRAM_NAME
