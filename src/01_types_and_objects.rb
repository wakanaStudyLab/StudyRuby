# frozen_string_literal: true

# ============================================================================
# Ruby 01: オブジェクト・シンボル・不変データ (Objects, Symbols, Data.define)
# ============================================================================
#
# 【他言語経験者（Rust, C#, Go, Java, Python）向け要点】
# 1. 「すべてがオブジェクト」の徹底:
#    - 数値 `1`、真偽値 `true`、空を表す `nil` もすべてクラスのインスタンス（メソッド呼び出し可能）。
#    - `1.to_s`, `nil.nil?`, `5.times { ... }`
#
# 2. シンボル (:symbol) vs 文字列 ("string"):
#    - 文字列: 変更可能 (Mutable)。同内容でも毎回新しいオブジェクト（メモリ）が生成される。
#    - シンボル: 不変 (Immutable)。同じ名前のシンボルはプロセス内で常に**同一のメモリアドレス (object_id)** を指す。
#    - ハッシュ（辞書）のキーにはシンボルを使うのが定石。
#
# 3. Data.define (Ruby 3.2+ 不変データクラス):
#    - C#の `record`、Javaの `record`、Pythonの `@dataclass(frozen=True)` に相当。
#    - ゲッター、等価性比較 (`==`)、`to_h` が自動定義される軽量不変オブジェクト。
#
# 4. 【最大の罠】Ruby では 0 や空文字 ""、空配列 [] は「すべて真 (truthy)」:
#    - Ruby で偽 (falsy) になるのは **`false` と `nil` のみ**。
#    - Python や JS と異なり、`if 0` は true になるので要注意！

module Sample
  module Types
    # ========================================================================
    # 1. 不変データクラスの定義 (Ruby 3.2+ Data.define)
    # ========================================================================
    UserProfile = Data.define(:id, :name, :age, :tags) do
      # メソッドを追加可能
      def adult?
        age >= 18
      end
    end

    def self.run
      puts "--- 1. Everything is an Object ---"
      puts "Class of 42:          #{42.class}"
      puts "Class of 'Hello':     #{'Hello'.class}"
      puts "Class of nil:         #{nil.class}"

      puts "\n--- 2. Symbols (:sym) vs Strings ('str') ---"
      str1 = "status"
      str2 = "status"
      sym1 = :status
      sym2 = :status

      puts "String object_id comparison (str1 == str2): #{str1 == str2}"
      puts "String memory comparison    (str1.equal?(str2)): #{str1.equal?(str2)} (Different Memory)"
      puts "Symbol memory comparison    (sym1.equal?(sym2)): #{sym1.equal?(sym2)} (Same Memory)"

      puts "\n--- 3. Immutable Data Class (Data.define - Ruby 3.2+) ---"
      user = UserProfile.new(
        id: "u-101",
        name: "Alice",
        age: 28,
        tags: %i[ruby rust backend]
      )

      puts "User Name:  #{user.name}"
      puts "User Age:   #{user.age}"
      puts "Is Adult?:  #{user.adult?}"
      puts "User Tags:  #{user.tags.inspect}"

      puts "\n--- 4. Truthy / Falsy Semantics (Trap for Python/JS devs) ---"
      # 0 や空文字列は Ruby では truthy
      zero_val = 0
      empty_str = ""
      nil_val = nil
      puts "Is 0 truthy?:        #{zero_val ? 'YES (Truthy)' : 'NO (Falsy)'}"
      puts "Is '' truthy?:       #{empty_str ? 'YES (Truthy)' : 'NO (Falsy)'}"
      puts "Is nil truthy?:      #{nil_val ? 'YES (Truthy)' : 'NO (Falsy)'}"
    end
  end
end

# 直接実行された場合
Sample::Types.run if __FILE__ == $PROGRAM_NAME
