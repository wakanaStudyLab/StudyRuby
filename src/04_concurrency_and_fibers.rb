# frozen_string_literal: true

# ============================================================================
# Ruby 04: 並行性・Fiber・Ractor (Concurrency, Fibers, and Ractors)
# ============================================================================
#
# 【他言語経験者（Rust, C#, Go, Java, Python）向け要点】
# 1. Fiber (コルーチン / 協調的軽量スレッド):
#    - Python の Generator / PHP の Fiber と同様に、`Fiber.yield` で一時停止し、
#      `fiber.resume` で再開します。
#
# 2. Thread (スレッド):
#    - Ruby のスレッドは OS のネイティブスレッドですが、GVL (Giant VM Lock) により
#      CPU 計算は同時に 1 つしか走れません (Python の GIL と同等)。
#    - Web API 呼び出しやファイル I/O などの待機処理には非常に有効。
#
# 3. Ractor (Ruby 3.0+ / Actor モデルによる真の並列計算):
#    - Erlang や Rust の Actix、Go の channel に似た **シェアードナッシング (メモリ非共有) 並列モデル**。
#    - GVL の制約を受けず、**マルチコア CPU を 100% 活用して並列計算** が可能。

module Sample
  module Async
    # ========================================================================
    # 1. Fiber による軽量コルーチン
    # ========================================================================
    def self.demonstrate_fibers
      generator = Fiber.new do
        puts "  [Fiber] Coroutine started"
        Fiber.yield("Step 1 Result")
        puts "  [Fiber] Resumed in Step 2"
        Fiber.yield("Step 2 Result")
        puts "  [Fiber] Coroutine completed"
        "Final Result"
      end

      puts "  [Main] Resume 1: #{generator.resume}"
      puts "  [Main] Resume 2: #{generator.resume}"
      puts "  [Main] Resume 3: #{generator.resume}"
    end

    # ========================================================================
    # 2. Thread による並行 I/O 処理
    # ========================================================================
    def self.demonstrate_threads
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      threads = (1..3).map do |i|
        Thread.new do
          # 擬似的な I/O 待ち
          sleep(0.05)
          "Task #{i} finished"
        end
      end

      # 全スレッドの完了を待機 (C# Task.WhenAll 相当)
      results = threads.map(&:value)
      elapsed_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000

      puts "  Thread Results: #{results.inspect}"
      puts "  Concurrent Execution Time: #{format('%.2f', elapsed_ms)} ms (Expected ~50ms)"
    end

    # ========================================================================
    # 3. Ractor による並列計算 (Ruby 3.0+ / GILフリー)
    # ========================================================================
    def self.demonstrate_ractors
      # CPU 計算を行う Ractor ワーカーを生成 (引数で安全にデータを渡す)
      worker = Ractor.new(1_000_000) do |n|
        # GIL を受けずにマルチコアで並列計算
        (1..n).sum { |i| i * i }
      end

      # 計算結果を取得 (Ruby 4.x では value, 3.x では take)
      parallel_result = worker.respond_to?(:value) ? worker.value : worker.take
      puts "  Ractor parallel computation result: #{parallel_result}"
    end

    def self.run
      puts "--- 1. Cooperative Multitasking with Fibers ---"
      demonstrate_fibers

      puts "\n--- 2. Concurrent I/O with Native Threads ---"
      demonstrate_threads

      puts "\n--- 3. True Parallelism with Ractors (Ruby 3.0+ / No GVL) ---"
      demonstrate_ractors
    end
  end
end

# 直接実行された場合
Sample::Async.run if __FILE__ == $PROGRAM_NAME
