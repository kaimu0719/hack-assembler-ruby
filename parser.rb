class Parser
  A_INSTRUCTION = :A_INSTRUCTION
  C_INSTRUCTION = :C_INSTRUCTION
  L_INSTRUCTION = :L_INSTRUCTION

  attr_reader :current_command

  # ファイルを開き、空行やコメントを除いて解析準備を行う
  def initialize(file_path)
    # ファイルの内容を配列として読み込む
    @lines = File.readlines(file_path, chomp: true)
                 .map { |line| line.split("//").first.strip } # コメント除去
                 .reject { |line| line.nil? || line.empty? }   # 空行除去

    @current_index = -1
    @current_command = nil
  end

  def has_more_lines?
    @current_index + 1 < @lines.size
  end

  ## 今日はここまで 2026/01/07

  # 次の命令を読み込み、それを現在の命令に設定する。
  # has_more_lines? が true のときにのみ呼び出すこと。
  def advance
    raise "No more commands" unless has_more_lines?

    @current_index += 1
    @current_command = @lines[@current_index]
  end

  # 現在の命令タイプを判別して返す
  def instruction_type
    if @current_command.start_with?("@")
      A_INSTRUCTION
    elsif @current_command.start_with?("(") && @current_command.end_with?(")")
      L_INSTRUCTION
    else
      C_INSTRUCTION
    end
  end

  def symbol
    case instruction_type
    when A_INSTRUCTION
      @current_command[1..] # '@'を除く
    when L_INSTRUCTION
      @current_command[1...-1] # '('と')'を除く
    else
      nil
    end
  end

  def dest
    return nil unless instruction_type == C_INSTRUCTION
    @current_command.include?("=") ? @current_command.split("=").first : nil
  end

  def comp
    return nil unless instruction_type == C_INSTRUCTION
    # dest=comp;jump → comp部分を抽出
    parts = @current_command.split("=")
    right = parts.size == 2 ? parts.last : parts.first
    right.split(";").first
  end

  def jump
    return nil unless instruction_type == C_INSTRUCTION
    @current_command.include?(";") ? @current_command.split(";").last : nil
  end
end
