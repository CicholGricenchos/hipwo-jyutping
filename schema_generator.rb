require 'csv'

class Generator
  attr_reader :spellers, :translators

  def initialize
    @spellers = []
    @translators = []
    csv = CSV.open('/Users/cichol/Documents/jyut.csv')
    @data = csv.read[1..-2]
  end

  def 声组合
    @data.map do |line|
      韵 = 分解韵(line[11])
      if 韵
        [line[10], *韵]
      end
    end.compact.uniq
  end

  def 分解韵 韵
    m = 韵.match /^(#{韵腹列表.join('|')})(#{韵尾列表.join('|')})?$/
    m && [m[1], m[2]]
  end

  def 声母变换
    {
      'ng' => 'v',
      'gw' => 'i',
      'kw' => 'q'
    }
  end

  def 韵腹变换
    {
      'aa' => 'x',
      'yu' => 'y',
      'eo' => 'v',
      'oe' => 'v'
    }
  end

  def 韵尾变换
    {
      'ng' => 'g'
    }
  end

  def 声母列表
    %w{b p m f d t n l g k ng h gw kw w z c s j}
  end

  def 韵腹列表
    %w{aa i u e o a yu oe eo}
  end

  def 韵尾列表
    %w{i u m n ng p t k}
  end

  def 生成变换声母
    声母变换.each do |from, to|
      spell "- xform/^#{from}/#{to.upcase}/"
      translate "- xform/(^|[ '])#{to}/$1#{from.upcase}/"
    end
  end

  def 生成原样声母
    声母列表.select{|x| x.size == 1}.each do |x|
      spell "- xform/^#{x}/#{x.upcase}/"
    end
  end

  def 带零韵腹
    声组合.select{|x| x[0].nil?}.map{|x| x[1]}.uniq
  end

  def 生成带零韵腹
    带零韵腹.each do |from|
      to = 韵腹变换[from] || from
      spell "- xform/^#{from}/#{to.upcase * 2}/"
      translate "- xform/(^|[ '])#{to * 2}/$1#{from.upcase}/"
    end
  end

  def 生成变换韵腹
    韵腹变换.each do |from, to|
      spell "- xform/#{from}/#{to.upcase}/"
      next if to == 'v'
      translate "- xform/(\\w)#{to}/$1#{from.upcase}/"
    end
  end

  def 生成原样韵腹
    韵腹列表.select{|x| x.size == 1}.each do |x|
      spell "- xform/#{x}/#{x.upcase}/"
    end
  end

  def 生成变换韵尾
    声组合.select{|x| x[1] == 'oe' || x[1] == 'eo'}.map{|x| [x[1], x[2]]}.uniq.each do |x|
      translate "- xform/(\\w)v#{韵尾变换[x[1]] || x[1]}$/$1#{x[0].upcase}#{x[1]&.upcase}/"
    end

    韵尾变换.each do |from, to|
      spell "- xform/#{from}$/#{to.upcase}/"
      translate "- xform/(\\w)#{to}/$1#{from.upcase}/"
    end
  end

  def 生成原样韵尾
    韵尾列表.select{|x| x.size == 1}.each do |x|
      spell "- xform/#{x}$/#{x.upcase}/"
    end
  end

  def 生成大小写变换
    spell "- xlit/#{('A'..'Z').to_a.join}/#{('a'..'z').to_a.join}/"
    translate "- xlit/#{('A'..'Z').to_a.join}/#{('a'..'z').to_a.join}/"
  end

  def 生成声母衍生
    spell "- derive/J/Y/"
    translate "- xform/(^|[ '])y/$1J/"
  end

  def 生成韵腹衍生
    spell "- derive/X/H/"
    translate "- xform/(\\w)h/$1AA/"
  end

  def 生成特例
    spell "- derive/^hng$/HN/"
    spell "- derive/^aa$/AA/"
    spell "- xform/^hng$/HG/"
    spell "- xform/^m$/MM/"
    spell "- xform/^ng$/NN/"

    translate "- xform/(^|[ '])hg/$1HNG/"
    translate "- xform/(^|[ '])hn/$1HNG/"
    translate "- xform/(^|[ '])mm/$1M/"
    translate "- xform/(^|[ '])nn/$1NG/"
    translate "- xform/(^|[ '])aa/$1AA/"
    translate "- xform/(^|[ '])ii/I$1GW/"
  end

  def spell line
    @spellers << line
  end

  def translate line
    @translators << line
  end

  def generate
    生成特例
    生成变换声母
    生成原样声母
    生成带零韵腹
    生成声母衍生
    生成变换韵腹
    生成原样韵腹
    生成韵腹衍生
    生成变换韵尾
    生成原样韵尾
    生成大小写变换
    self
  end
end

puts "***** SPELLERS *****"
puts Generator.new.generate.spellers
puts
puts "***** TRANSLATORS *****"
puts Generator.new.generate.translators