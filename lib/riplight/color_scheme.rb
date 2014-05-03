module Riplight
  module ColorScheme
    NAMES = {
      'tomorrow' => 'Tomorrow::Theme'
    }
    
    autoload 'Tomorrow', 'riplight/color_scheme/tomorrow'
    
    def self.get_by_name(name)
      const_get NAMES[name]
    end
  end
end