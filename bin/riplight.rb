require 'ripper'
require 'pp'
require 'rtf'

tokens = Ripper.lex(ARGF.read)

pp tokens
exit

def check_tokens_structure(tokens)
  tokens.each_cons(2) do |e1, e2|
    if e1[0][0] == e2[0][0]   # same line
      if e2[0][1] != e1[0][1] + e1[2].size
        raise "wtf #{e2.inspect}"
      end
    end
  end
end

tommorrow = {
  background: 'ffffff',
  foreground: '4d4d4c',
  comment: '8e908c',
  red: 'c82829',
  green: '718c00',
}

colors = {
  keyword: tommorrow[:green],
  comment: tommorrow[:comment],
  symbol: tommorrow[:red],
}
colors.default = tommorrow[:foreground]

def style_from_color(color)
  raise ArgumentError, "Bad color: #{color.inspect}" unless color =~ /\A[0-9a-f]{6}\Z/i
  components = color.scan(/../).map { |s| Integer(s, 16) }
  style = RTF::CharacterStyle.new
  style.foreground = RTF::Colour.new(*components)
  style
end

$styles = {}
colors.each do |k, color|
  $styles[k] = style_from_color(color)
end
$styles.default = style_from_color(colors.default)


def style_for_token(token_type, token_string)
  case token_type
  when :on_kw then $styles[:keyword]
  else $styles.default
  end
end

check_tokens_structure(tokens)

font = RTF::Font.new(RTF::Font::MODERN, 'Source Code Pro')
document = RTF::Document.new(font)
document.paragraph do |paragraph|
  last_line = nil
  tokens.each do |token_data|
    coords, token_type, token_string = token_data
    line, char = coords
    if last_line && line != last_line
      paragraph.line_break
    end
    paragraph.apply(style_for_token(token_type, token_string)) do |n2|
      n2 << token_string
    end
    last_line = line
  end
end

File.open('my_document.rtf', 'wb') { |f| f.write(document.to_rtf) }