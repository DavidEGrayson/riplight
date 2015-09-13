module Riplight
  class RtfWriter
    def initialize(file)
      @file = file
    end

    def start(font_name)
      @file.puts "{\\rtf1{\\fonttbl{\\f0\\fnil\\fcharset0 #{font_name};}}"
    end

    def font_color_table(colors)
      @file.puts '{\\colortbl'
      colors.each_with_index do |color, index|
        red, green, blue, comment = color

        rtf_color = '\\red%d \\green%d \\blue%d ;' % [red, green, blue]

        rtf_comment = "#{index}"
        rtf_comment += " #{comment}" if comment

        @file.puts '%-28s %%%% %s' % [rtf_color, rtf_comment]
      end
      @file.puts '}'
    end

    def font_size(size)
      cmd 'fs', size
    end

    def font_color(index)
      cmd 'cf', index
    end

    def paragraph
      cmd 'par'
    end

    def text(string)
      string = string.gsub(/{|}|\\|\n/) do |m|
        if m == "\n"
          "\\line\n"
        else
          '\\' + m
        end
      end
      @file.print string
    end

    private
    def cmd(cmd, arg = nil)
      @file.print "\\#{cmd}#{arg} "
    end
  end
end
