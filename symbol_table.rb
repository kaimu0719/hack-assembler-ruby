class SymbolTable
  def initialize
    @table = {}

    # 予約済みシンボル
    @table["SP"]   = 0
    @table["LCL"]  = 1
    @table["ARG"]  = 2
    @table["THIS"] = 3
    @table["THAT"] = 4

    # R0~R15の登録
    0.upto(15) do |i|
      @table["R#{i}"] = i
    end

    # スクリーンとキーボード
    @table["SCREEN"] = 16384
    @table["KBD"] = 24576
  end

  def addEntry(symbol, address)
    @table[symbol] = address
  end

  def contains?(symbol)
    @table.key?(symbol)
  end

  def getAddress(symbol)
    @table[symbol]
  end
end
