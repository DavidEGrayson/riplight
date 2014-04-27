require 'ripper'

module Riplight
  module Lexer
    # @param source (String)
    # @param filename (String)
    # @param line_number (Integer)
    def self.lex(source, filename = '-', line_number = 1)
      ripper_tokens = Ripper.lex(source, filename, line_number)
      fix_simple_symbols(ripper_tokens)
      fix_string_symbols(ripper_tokens)
      tokens = ripper_tokens.map do |ripper_token|
        convert_ripper_token ripper_token
      end
      tokens.concat leftovers(source, ripper_tokens)
      tokens
    end

    def self.convert_ripper_token(ripper_token)
      coords, ripper_token_type, string = ripper_token
      [string, token_type(ripper_token_type)]
    end

    def self.token_type(ripper_token_type)
      case ripper_token_type
      when :on_CHAR, :on_backtick, :on_tstring_beg, :on_tstring_content, :on_tstring_end,
           :on_words_beg, :on_qwords_beg, :on_symbols_beg, :on_qsymbols_beg, :on_words_sep then :string
      when :on_backref then :global_var
      when :on_comma then :comma
      when :on_comment, :on_embdoc_beg, :on_embdoc, :on_embdoc_end then :comment
      when :on_const then :constant
      when :on_cvar then :class_var
      when :on_embexpr_beg, :on_embexpr_end, :on_embvar then :interpolation_mark
      when :on_gvar then :global_var
      when :on_heredoc_beg then :heredoc_begin
      when :on_heredoc_end then :heredoc_end
      when :on_ident then :identifier
      when :on_int, :on_float then :number
      when :on_ivar then :instance_var
      when :on_kw, :on___end__ then :keyword
      when :on_lbrace, :on_rbrace then :brace
      when :on_lbracket, :on_rbracket then :bracket
      when :on_lparen, :on_rparen then :paren
      when :on_op then :operator
      when :on_period then :period
      when :on_sp, :on_ignored_nl, :on_nl then :space
      when :on_symbeg, :on_label then :symbol
      else ripper_token_type
      end
    end

    private

    # Combine :on_symbeg with :on_identifier immediately after it
    # because everyone expects a syntax highlighter to do that.
    def self.fix_simple_symbols(ripper_tokens)
      # DANGER: Iterating over an array while shortening it
      ripper_tokens.each_index do |index|
        next unless ripper_tokens[index][1] == :on_symbeg && ripper_tokens[index + 1][1] == :on_ident
        merge_ripper_tokens(ripper_tokens, index, 2)
      end
    end

    # Split an :on_symbeg with ':"' into two pieces so that if people want to color
    # strings and symbols differently those characters will be the right colors.
    def self.fix_string_symbols(ripper_tokens)
      # DANGER: Iterating over an array while increasing its length
      values = %w{ :" :' }
      pp values
      ripper_tokens.each_index do |index|
        token = ripper_tokens[index]
        next unless token[1] == :on_symbeg && values.include?(token[2])
        row, column = token[0]
        new_tokens = [
          [[row, column], :on_symbeg, ':'],
          [[row, column + 1], :on_tstring_beg, token[2][1]],
        ]
        ripper_tokens[index, 1] = new_tokens
      end
    end

    def self.merge_ripper_tokens(ripper_tokens, index, length)
      tokens = ripper_tokens[index, length]
      str = tokens.map { |t| t[2] }.join
      ripper_tokens[index, length] = [[tokens[0][0], tokens[0][1], str]]
    end

    def self.leftovers(source, ripper_tokens)
      last_token = ripper_tokens.last
      row, column = last_token[0]
      column += last_token[2].size
      str = string_starting_at_coords(source, row, column)

      return [] if str.empty?

      leftover_type = last_token[1] == :on___end__ ? :end_data : :unknown
      [[str, leftover_type]]
    end

    def self.string_starting_at_coords(string, row, column)
      regexp = Regexp.new("(?:.*?\n){#{row - 1}}.{#{column}}(.*)", Regexp::MULTILINE)
      string.slice(regexp, 1)
    end
  end
end