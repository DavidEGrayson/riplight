require 'spec_helper'

# TODO: make sure we handle everything in Ripper::SCANNER_EVENTS
# TODO: describe encoding issues
# TODO: describe newline issues
# TODO: describe trailing and leading whitespace issues

describe Riplight::Lexer do
  def lex(*args)
    described_class.lex *args
  end

  it 'returns leftovers that Ripper could not lex' do
    expect(lex(' 0x')).to eq [
      [" ", :space],
      ['0x', :unknown],
    ]
  end

  it 'identifies whitespace' do
    expect(lex(" \n\t  ")).to eq [
      [" ", :space],
      ["\n", :space],
      ["\t  ", :space],
    ]
  end

  keywords = %w{
    BEGIN END __ENCODING__ __END__ __FILE__ __LINE__
    alias and begin break case class def defined? do else elsif end ensure false
    for if in module next nil not or redo rescue retry return self super then
    true undef unless until when while yield
  }

  keywords.each do |keyword|
    it "identifies #{keyword} as a keyword" do
      expect(lex(keyword)).to eq [[keyword, :keyword]]
    end
  end

  operators = %w{
    + - / * % ** == != > < >= <= <=> === = += -= *= /= %= **= =~ !~
    <<= >>= &= |= ^= &&= ||= ^ | & ~ << >> && || ! ? .. ... ::
  }

  operators.each do |operator|
    it "identifies #{operator} as an operator" do
      expect(lex("b #{operator} c")).to eq [
        ['b', :identifier],
        [' ', :space],
        [operator, :operator],
        [' ', :space],
        ['c', :identifier],
      ]
    end
  end

  it 'identifies the ternary operator' do
    expect(lex("a ? b : c")).to eq [
      ['a', :identifier],
      [' ', :space],
      ['?', :operator],
      [' ', :space],
      ['b', :identifier],
      [' ', :space],
      [':', :operator],
      [' ', :space],
      ['c', :identifier],
    ]
  end

  it 'identifies period' do
    expect(lex('.')).to eq [['.', :period]]
  end

  it 'identifies method calls as a identifiers even if they look like keywords' do
    expect(described_class.lex('self.return')).to eq [
      ["self", :keyword],
      [".", :period],
      ["return", :identifier],
    ]
  end

  it 'identifies constants in class definitions' do
    expect(lex('class A')).to eq [
      ['class', :keyword],
      [' ', :space],
      ['A', :constant],
    ]
  end

  it 'identifies character literals as strings' do
    expect(lex('?t')).to eq [['?t', :string]]
  end

  it 'identifies single-quoted string' do
    expect(lex("'abc'")).to eq [
      [?', :string],
      ['abc', :string],
      [?', :string],
    ]
  end

  it 'identifies double-quoted strings' do
    expect(lex('"abc"')).to eq [
      [?", :string],
      ['abc', :string],
      [?", :string],
    ]
  end

  context 'inside a double-quoted string' do
    it 'identifies embedded expressions' do
      expect(lex('"#{b}"')).to eq [
        [?", :string],
        ['#{', :interpolation_mark],
        ['b', :identifier],
        ['}', :interpolation_mark],
        [?", :string]
      ]
    end

    it 'identifies embedded instance variables' do
      expect(lex('"#@a"')).to eq [
        [?", :string],
        ['#', :interpolation_mark],
        ['@a', :instance_var],
        [?", :string],
      ]
    end
  end

  it 'identifies backticks' do
    # Unfortunately, this means you can't color backticks differently from normal strings.
    expect(lex('`ls`')).to eq [
      ['`', :string],
      ['ls', :string],
      ['`', :string],
    ]
  end

  it 'identifies regular expression' do
    # Unfortunately, this means you can't color regexes differently from normal strings.
    expect(lex('/a/m')).to eq [
      ['/', :string],
      ['a', :string],
      ['/m', :string],
    ]
  end

  it 'identifies commas' do
    expect(lex(',')).to eq [[',', :comma]]
  end

  it 'identifies semicolons' do
    expect(lex(';')).to eq [[';', :semicolon]]
  end

  it 'identifies comments' do
    expect(lex('# hi')).to eq [['# hi', :comment]]
  end

  describe 'strings starting with %' do
    it 'identifies %q strings' do
      expect(lex('%q{hi}')).to eq [
        ['%q{', :string],
        ['hi', :string],
        ['}', :string],
      ]
    end

    it 'identifies %Q strings' do
      expect(lex('%Q{hi}')).to eq [
        ['%Q{', :string],
        ['hi', :string],
        ['}', :string],
      ]
    end
  end

  describe 'arrays starting with %' do
    it 'identifies %w arrays of words' do
      expect(lex('%w[a b]')).to eq [
        ['%w[', :string],
        ['a', :string],
        [' ', :string],
        ['b', :string],
        [']', :string],
      ]
    end

    it 'identifies %W arrays of symbols' do
      expect(lex('%W[a b]')).to eq [
        ['%W[', :string],
        ['a', :string],
        [' ', :string],
        ['b', :string],
        [']', :string],
      ]
    end

    it 'identifies %i arrays of symbols' do
      # Unfortunately, we don't make it possible to color %i differently from %w.
      expect(lex('%i[a b]')).to eq [
        ['%i[', :string],
        ['a', :string],
        [' ', :string],
        ['b', :string],
        [']', :string],
      ]
    end

    it 'identifies %I arrays of symbols' do
      expect(lex('%I[a b]')).to eq [
        ['%I[', :string],
        ['a', :string],
        [' ', :string],
        ['b', :string],
        [']', :string],
      ]
    end
  end

  describe 'variables' do
    it 'identifies instance variables' do
      expect(lex('@a')).to eq [['@a', :instance_var]]
    end

    it 'identifies class variables' do
      expect(lex('@@a')).to eq [['@@a', :class_var]]
    end

    it "identifies constants" do
      expect(lex('ABC')).to eq [['ABC', :constant]]
    end

    it "identifies constants that are actually method calls", flaw: true do
      expect(lex('A()')[0]).to eq ['A', :constant]
    end

    it 'identifies normal global variables' do
      expect(lex('$f')).to eq [['$f', :global_var]]
    end

    it 'identifies backrefs as global variables' do
      expect(lex('$1')).to eq [['$1', :global_var]]
    end
  end

  describe 'numbers' do
    it 'identifies decimal integers' do
      expect(lex('44')).to eq [['44', :number]]
    end

    it 'identifies floats' do
      expect(lex('44.0')).to eq [['44.0', :number]]
    end
  end

  it 'identifies heredocs' do
    expect(lex("puts(<<END)\nline1\nline2\nEND")).to eq [
      ['puts', :identifier],
      ['(', :paren],
      ['<<END', :string],
      [')', :paren],
      ["\n", :space],
      ["line1\nline2\n", :string],
      ["END", :string],
    ]
  end

  it 'identifies embedded documentation as a comment' do
    expect(lex("=begin\nhi\n=end")).to eq [
      ["=begin\n", :comment],
      ["hi\n", :comment],
      ["=end", :comment],
    ]
  end

  it 'identifies braces in hash table' do
    expect(lex('{}')).to eq [
      ['{', :brace],
      ['}', :brace],
    ]
  end

  it 'identifies braces in block' do
    expect(lex('loop{}')).to eq [
      ['loop', :identifier],
      ['{', :brace],
      ['}', :brace],
    ]
  end

  it 'identifies brackets for making an array' do
    expect(lex('[]')).to eq [
      ['[', :bracket],
      [']', :bracket],
    ]
  end

  it 'identifies brackets for calling a method' do
    expect(lex('a[]')).to eq [
      ['a', :identifier],
      ['[', :bracket],
      [']', :bracket],
    ]
  end

  it 'identifies lambas' do
    expect(lex('->(a){a+1}')). to eq [
      ['->', :lambda],
      ['(', :paren],
      ['a', :identifier],
      [')', :paren],
      ['{', :brace],
      ['a', :identifier],
      ['+', :operator],
      ['1', :number],
      ['}', :brace]
    ]
  end

  describe 'symbols' do
    it 'identifies simple symbols' do
      # This requires merging a :on_symbeg to an :on_ident!
      expect(lex(':s')).to eq [
        [':s', :symbol]
      ]
    end

    it 'handles multiple symbol symbols and leftovers' do
      expect(lex(':a+:b+:c+:d')).to eq [
        [':a', :symbol],
        ['+', :operator],
        [':b', :symbol],
        ['+', :operator],
        [':c', :symbol],
        ['+', :operator],
        [':d', :symbol],
      ]
    end

    it 'identifies symbols made with double-quoted strings' do
      # This kind of output makes us incompatible with Sublime Text because it likes
      # to highlight :"s" as a symbol, but I think our way is more correct and it
      # would look inconsistent if adding a little bit of interpolation changed
      # the color of the symbol.
      expect(lex(':"s"')).to eq [
        [':', :symbol],
        [?", :string],
        ['s', :string],
        [?", :string],
      ]
    end

    it 'identifies symbols made with single-quoted strings' do
      expect(lex(":'s'")).to eq [
        [':', :symbol],
        [?', :string],
        ['s', :string],
        [?', :string],
      ]
    end

    it 'idenfities multiple symbols made with strings' do
      expect(lex(":'s'+" * 5)).to eq [
        [':', :symbol],
        [?', :string],
        ['s', :string],
        [?', :string],
        ['+', :operator],
      ] * 5
    end

    it 'identifies symbols with double-quoteded strings and interpolation' do
      expect(lex(':"s#{a}"')).to eq [
        [':', :symbol],
        ['"', :string],
        ['s', :string],
        ['#{', :interpolation_mark],
        ['a', :identifier],
        ['}', :interpolation_mark],
        ['"', :string]
      ]
    end

    it 'considers labels to be symbols' do
      expect(lex('{b:4}')).to eq [
        ['{', :brace],
        ['b:', :symbol],
        ['4', :number],
        ['}', :brace],
      ]
    end
  end

  describe '__END__ keyword' do
    it 'identifies __END__ and includes the data after it' do
      expect(lex("hi\n__END__\ndata1\ndata2")).to eq [
        ['hi', :identifier],
        ["\n", :space],
        ["__END__\n", :keyword],
        ["data1\ndata2", :end_data]
      ]
    end

    it 'does not recognize __END__ unless it is on its own line' do
      expect(lex("hi\n__END__ ")).to eq [
        ['hi', :identifier],
        ["\n", :space],
        ['__END__', :identifier],
        [' ', :space],
      ]
    end
  end

  describe 'all events in Ripper::SCANNER_EVENTS' do
    Ripper::SCANNER_EVENTS.each do |name|
      name = "on_#{name}".to_sym
      it "handles #{name.inspect}" do
        expect(described_class.token_type(name)).to_not eq name
      end
    end
  end
end