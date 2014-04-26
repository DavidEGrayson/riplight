require 'spec_helper'

describe Riplight::Lexer do
  it 'identifies whitespace' do
    expect(described_class.lex(" \n\t  ")).to eq [
      [" ", :space],
      ["\n", :space],
      ["\t  ", :space],
    ]
  end

  keywords = %w{
    alias and begin break case class def defined? do else elsif end ensure false
    for if in module next nil not or redo rescue retry return self super then
    true undef unless until when while yield
  }
  
  keywords.each do |keyword|
    it "identifies #{keyword} as a keyword" do
      expect(described_class.lex(keyword)).to eq [[keyword, :keyword]]    
    end
  end
  
  it 'identifies period' do
    expect(described_class.lex('.')).to eq [['.', :period]]
  end
  
  it 'identifies method calls as a identifiers even if they look like keywords' do
    expect(described_class.lex('self.return')).to eq [
      ["self", :keyword],
      [".", :period],
      ["return", :identifier],
    ]
  end
  
  it "identifies constants" do
    expect(described_class.lex('ABC')).to eq [['ABC', :constant]]
  end
  
  it "identifies constants that are actually method calls", flaw: true do
    expect(described_class.lex('A()')[0]).to eq ['A', :constant]
  end
end