require 'ripper'

module Riplight
  module Lexer
    def self.lex(source, filename = '-', line_number = 1)
      ripper_tokens = Ripper.lex(source, filename, line_number)
      ripper_tokens.map do |ripper_token|
        convert_ripper_token ripper_token
      end
    end
    
    def self.convert_ripper_token(ripper_token)
      coords, ripper_token_type, string = ripper_token
      [string, token_type(ripper_token_type)]
    end
    
    def self.token_type(ripper_token_type)
      case ripper_token_type
      when :on_const then :constant
      when :on_kw then :keyword
      when :on_period then :period
      when :on_sp, :on_ignored_nl then :space
      when :on_ident then :identifier
      else ripper_token_type
      end
    end
  end
end