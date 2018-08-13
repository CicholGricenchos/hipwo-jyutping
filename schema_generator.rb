class Generator
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
      'oe' => 'v',
      'ng' => 'n',
      'm' => 'm'
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
    %w{aa i u e o a yu oe eo ng m}
  end

  def 韵尾列表
    %w{i u m n ng p t k}
  end

  def initialize output = STDOUT
    @output = output
  end

  def 生成变换声母
    声母变换.each do |from, to|
      output "- xform/^#{from}/#{to.upcase}/"
    end
  end

  def 生成原样声母
    声母列表.select{|x| x.size == 1}.each do |x|
      output "- xform/^#{x}/#{x.upcase}/"
    end
  end

  def 生成带零韵腹
    韵腹列表.each do |from|
      to = 韵腹变换[from] || from
      output "- xform/^#{from}/#{to.upcase * 2}/"
    end
  end

  def 生成变换韵腹
    韵腹变换.each do |from, to|
      # 鼻音独立韵必须配合零声母使用
      next if from == 'ng'
      next if from == 'm'
      output "- xform/#{from}/#{to.upcase}/"
    end
  end

  def 生成原样韵腹
    韵腹列表.select{|x| x.size == 1}.each do |x|
      output "- xform/#{x}/#{x.upcase}/"
    end
  end

  def 生成变换韵尾
    韵尾变换.each do |from, to|
      output "- xform/#{from}$/#{to.upcase}/"
    end
  end

  def 生成原样韵尾
    韵尾列表.select{|x| x.size == 1}.each do |x|
      output "- xform/#{x}$/#{x.upcase}/"
    end
  end

  def 生成大小写变换
    output "- xlit/#{('A'..'Z').to_a.join}/#{('a'..'z').to_a.join}/"
  end

  def 生成声母衍生
    output "- derive/J/Y/"
  end

  def 生成韵腹衍生
    output "- derive/X/H/"
  end

  def 生成特例
    output "- derive/^hng$/HN/"
    output "- derive/^aa$/AA/"
  end

  def output line
    @output.puts line
  end

  def generate_speller
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
  end

  def generate
    generate_speller
  end
end

Generator.new.generate