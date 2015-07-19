require 'rtf'

module Riplight
  class Rtf
    def self.output(tokens, theme)
      new(theme).output(tokens)
    end
  
    Font = RTF::Font.new(RTF::Font::MODERN, 'Source Code Pro')
  
    def initialize(theme)
      @theme = theme
    end
  
    def style_from_color(color)
      raise ArgumentError, "Bad color: #{color.inspect}" unless color =~ /\A[0-9a-f]{6}\Z/i
      components = color.scan(/../).map { |s| Integer(s, 16) }
      style = RTF::CharacterStyle.new
      style.foreground = RTF::Colour.new(*components)
      style
    end
    
    def style_for_token(token_type)
      style_from_color(@theme[token_type] || @theme[:foreground])
    end
    
    def output(tokens)
      document = document(tokens)
      File.open('my_document.rtf', 'wb') { |f| f.write(document.to_rtf) }
    end
    
    def document(tokens)
      document = RTF::Document.new(Font)
      document.paragraph do |paragraph|
        last_line = nil
        tokens.each do |token_data|
          token_string, token_type = token_data
          paragraph.apply(style_for_token(token_type)) do |n2|
            add_text n2, token_string
          end          
        end
      end
      document
    end
    
    def add_text(node, text)
      p text
      text.each_line do |line|
        node << line.chomp.gsub('\\', ';')
        if line.end_with?("\n")
          node.line_break
        end
      end
    end
  end
end