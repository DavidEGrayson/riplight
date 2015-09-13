module Riplight
  module ColorUtils
    def self.hex_color_parse(hex)
      raise "bad hex color" if !hex.match(/[0-9a-f]{6,}/i)

      [hex[0, 2].to_i(16), hex[2, 2].to_i(16), hex[4, 2].to_i(16)]
    end
  end
end
