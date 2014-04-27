require 'ripper'

module Riplight
  module Lexer
    # @param source (String)
    # @param filename (String)
    # @param line_number (Integer)
    def self.lex(source, filename = '-', line_number = 1)
      ripper_tokens = Ripper.lex(source, filename, line_number)
      tokens = ripper_tokens.map do |ripper_token|
        convert_ripper_token ripper_token
      end
      add_end_data(source, ripper_tokens, tokens)
      tokens
    end

    def self.convert_ripper_token(ripper_token)
      coords, ripper_token_type, string = ripper_token
      [string, token_type(ripper_token_type)]
    end

    def self.token_type(ripper_token_type)
      case ripper_token_type
      when :on_const then :constant
      when :on_kw, :on___end__ then :keyword
      when :on_period then :period
      when :on_sp, :on_ignored_nl, :on_nl then :space
      when :on_ident then :identifier
      else ripper_token_type
      end
    end

    private

    def self.add_end_data(source, ripper_tokens, tokens)
      last_token = ripper_tokens.last
      return unless last_token[1] == :on___end__
      end_row, end_column = last_token[0]
      pp [end_column, last_token[2].size]
      data_column = end_column + last_token[2].size
      data = string_starting_at_coords(source, end_row, data_column)

      if !data.empty?
        tokens << [data, :end_data]
      end
    end

    def self.string_starting_at_coords(string, row, column)
      regexp = Regexp.new("(?:.*?\n){#{row - 1}}.{#{column}}(.*)", Regexp::MULTILINE)
      string.slice(regexp, 1)
    end
  end
end