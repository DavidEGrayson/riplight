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

  it "identifies constants" do
    expect(lex('ABC')).to eq [['ABC', :constant]]
  end

  it 'identifies constants in class definitions' do
    expect(lex('class A')).to eq [
      ['class', :keyword],
      [' ', :space],
      ['A', :constant],
    ]
  end

  it "identifies constants that are actually method calls", flaw: true do
    expect(lex('A()')[0]).to eq ['A', :constant]
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
end