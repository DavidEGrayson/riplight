# Class
class Riplight::Person
  attr_accessor :name
end

# Module name
ActiveModel::Conversion

# Method definitions
def initialize(arg1, opts = {})
end

# Keyword argumentss
def foobar(kw1: foo, kw2: 123)
end

# Instance variables
@polite_name = "Ms. " + @name

# Escaped newline
"hi" \
"there"

# Symbols
:symbol
:'symbol'
:"symbol"

# Interpolation or lack thereof.
'foo #{here} #@ivar'
%q{foo #{here} #@ivar}
"foo #{here} #@ivar"
%Q{foo #{here} #@ivar}
`foo #{expr} #@ivar`
%x{foo #{expr} #@ivar}
:"foo #{expr} #@ivar #$global"

# Character literals
?c + ??

# Hashes
{ :foo1 => 1,
  :'foo2' => 1,
  :"foo3" => 1,
  foo4: 1,
  'foo5': 1,
  "foo6": 1,
}

# Regular expression
/regex #{a}/i

# Lambda
lambda = ->(a) { a + 2 }

# Block with brackets
people.select { |p| p.here? }

# Block with do/end
people.select do |p|
  p.here?
end

# Keywords
keywords.each do
  alias :a :z
  defined?(healthy) and happy until 1
  super(1, 2)

  while true or false
    yield self, nil
  end

  begin
    fail unless __ENCODING__
  rescue
    puts __FILE__, __LINE__
    redo
    retry
  ensure
  end

  case x
  when 1 then break
  when 2 then next
  end

  if x; then true; elsif y; false; else; end
end
module Mod
  class Klass
    def method
    end
    undef method
  end
end
BEGIN { }
END { }

# Data at the end of a file.
__END__
more stuff "not highlighted"
