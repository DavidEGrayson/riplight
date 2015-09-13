require 'riplight'
require 'optparse'

# TODO: allow specifying output file

options = { theme: 'tomorrow', output: 'html' }
option_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: riplight.rb [options] FILE'

  opts.on('-t', '--theme THEME', 'Specify color theme.') do |theme|
    options[:theme] = theme
  end

  opts.on('-f', '--output-format FORMAT', 'Specify kind of output.') do |format|
    options[:output_format] = format
  end
end

option_parser.parse!

theme = Riplight::ColorScheme.get_by_name(options[:theme])

case options.fetch(:output_format, 'rtf').downcase
when 'html'
  outputter = Riplight::Html  # TODO: make this
when 'rtf'
  outputter = Riplight::Rtf
end

source = ARGF.read
tokens = Riplight::Lexer.lex(source)
outputter.output STDOUT, tokens, theme
