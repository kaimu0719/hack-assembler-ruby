# 使用方法: ruby main.rb Prog.asm
# 出力: Prog.hack

require_relative "parser"
require_relative "code"
require_relative "symbol_table"

class HackAssembler
  def initialize(file_path)
    @file_path = file_path
    @parser = Parser.new(file_path)
    @code = Code.new
    @symbol_table = SymbolTable.new

    # ROMのアドレス15まではすでに使用されているのでアドレス16から新規に登録していく
    @next_variable_address = 16
  end

  def first_pass
    rom_address = 0

    while @parser.has_more_lines?
      @parser.advance

      case @parser.instruction_type
      when Parser::L_INSTRUCTION
        symbol = @parser.symbol

        if @symbol_table.contains?(symbol) == false
          @symbol_table.addEntry(symbol, rom_address)
        end
      else
        # A命令またはC命令の場合はROMアドレスを加算する
        rom_address += 1
      end
    end
  end

  def second_pass
    # 最初から解析をやり直すためparserのインスタンスを再生成している
    @parser = Parser.new(@file_path)

    # バイナリデータを記述するためのファイルを作成する
    output_file_path = @file_path.sub(/\.asm$/, ".hack")

    File.open(output_file_path, "w") do |file|
      while @parser.has_more_lines?
        # 次の命令を読み込み、現在の命令に設定する。
        @parser.advance

        case @parser.instruction_type
        when Parser::A_INSTRUCTION
          symbol = @parser.symbol

          # 数値の場合
          if symbol.match?(/^\d+$/)
            address = symbol.to_i
          else
            @symbol_table.addEntry(symbol, @next_variable_address)
            address = @next_variable_address
            @next_variable_address += 1
          end
        end

        binary = format("%016b", address)
        file.puts(binary)

        when Parser::C_INSTRUCTION
          comp_bits = @code.comp(@parser.comp)
          dest_bits = @code.dest(@parser.dest)
          jump_bits = @code.jump(@parser.jump)
          binary = "111" + comp_bits + dest_bits + jump_bits
          file.puts(binary)
      end
    end
  end

  def assemble
    # バイナリデータを記述するためのファイルを作成する
    output_file_path = @file_path.sub(/\.asm$/, ".hack")

    File.open(output_file_path, "w") do |file|
      while @parser.has_more_lines?
        # 次の命令を読み込み、現在の命令に設定する。
        @parser.advance

        case @parser.instruction_type
        when Parser::A_INSTRUCTION
          value = @parser.symbol.to_i
          binary = format("%016b", value)
          file.puts(binary)

        when Parser::C_INSTRUCTION
          comp_bits = @code.comp(@parser.comp)
          dest_bits = @code.dest(@parser.dest)
          jump_bits = @code.jump(@parser.jump)
          binary = "111" + comp_bits + dest_bits + jump_bits
          file.puts(binary)

        when Parser::L_INSTRUCTION
          # TODO: シンボルテーブルを作成したのちに作成する必要がある
        end
      end
    end

    puts "✅ Assembled successfully: #{output_file_path}"
  end
end

if ARGV.length != 1
  puts "Usage: ruby main.rb Prog.asm"
  exit
end

assenbler = HackAssembler.new(ARGV[0])
assenbler.assemble