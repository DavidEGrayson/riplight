require 'riplight/rtf_writer'
require 'riplight/color_utils'
require 'stringio'

module Riplight
  class Rtf
    def self.output(io, tokens, theme)
      new(theme).output(io, tokens)
    end

    def initialize(theme)
      @theme = theme
      initialize_color_table
    end

    def initialize_color_table
      @color_index_by_token_type = {}
      @color_table = []

      @theme.each do |token_type, hex_color|
        next if token_type == :background

        hex_color ||= @theme[:foreground]
        red, green, blue = ColorUtils.hex_color_parse hex_color

        @color_index_by_token_type[token_type] = @color_table.size
        @color_table << [red, green, blue, token_type.to_s]
      end
    end

    def color_index_for_token(token_type)
      @color_index_by_token_type.fetch(token_type)
    end

    def output(io, tokens)
      @rtf = RtfWriter.new(io)
      rtf.start 'Source Code Pro'
      rtf.font_color_table @color_table
      tokens.each do |token|
        text, token_type = token
        rtf.font_color color_index_for_token(token_type)
        rtf.text text
      end
    end

    private

    attr_reader :rtf

  end
end
