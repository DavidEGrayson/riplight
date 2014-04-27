require 'spec_helper'

# TODO: make sure we handle everything in Ripper::SCANNER_EVENTS
# TODO: describe encoding issues
# TODO: describe newline issues
# TODO: describe trailing and leading whitespace issues

describe Riplight::Lexer do
  def lex(*args)
    described_class.lex *args
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
    expect(lex('`ls`')).to eq [
      ['`', :string],
      ['ls', :string],
      ['`', :string],
    ]
  end

  it 'identifies commas' do
    expect(lex(',')).to eq [[',', :comma]]
  end

  it 'identifies comments' do
    expect(lex('# hi')).to eq [['# hi', :comment]]
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
    it 'identifies integers' do
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
      ['<<END', :heredoc_begin],
      [')', :paren],
      ["\n", :space],
      ["line1\nline2\n", :string],
      ["END", :heredoc_end],
    ]
  end

  it 'identifies embedded documentation as a comment' do
    expect(lex("=begin\nhi\n=end")).to eq [
      ["=begin\n", :comment],
      ["hi\n", :comment],
      ["=end", :comment],
    ]
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