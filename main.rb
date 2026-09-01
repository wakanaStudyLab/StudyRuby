# frozen_string_literal: true

# ============================================================================
# Modern Ruby (Ruby 3.0+) Crash Course - Main Runner
# For Rust / C# / Go / Java / Python / TS Developers
# ============================================================================

require_relative "src/01_types_and_objects"
require_relative "src/02_blocks_and_enumerable"
require_relative "src/03_oop_and_modules"
require_relative "src/04_concurrency_and_fibers"

def print_banner(title)
  puts "\n#{'=' * 64}"
  puts "  #{title}"
  puts "#{'=' * 64}\n\n"
end

def print_section(title)
  puts "\n#{'#' * 64}"
  puts "# #{title}"
  puts "#{'#' * 64}\n\n"
end

def main
  print_banner("MODERN RUBY CRASH COURSE (Running on Ruby #{RUBY_VERSION})")

  print_section("01: Objects, Symbols, and Immutable Data (Data.define)")
  Sample::Types.run

  print_section("02: Blocks, Enumerable Pipeline, and Pattern Matching")
  Sample::Control.run

  print_section("03: OOP, Mix-in Modules, and Metaprogramming")
  Sample::OOP.run

  print_section("04: Fibers, Native Threads, and Parallelism (Ractor)")
  Sample::Async.run

  print_banner("ALL RUBY TUTORIAL MODULES COMPLETED SUCCESSFULLY!")
end

main if __FILE__ == $PROGRAM_NAME
