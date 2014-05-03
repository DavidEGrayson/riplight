# Source: https://github.com/ChrisKempson/Tomorrow-Theme

module Riplight::ColorScheme
  module Tomorrow
    Base = {
      background: 'ffffff',
      current_line: 'efefef',
      selection: 'd6d6d6',
      foreground: '4d4d4c',
      comment: '8e908c',
      red: 'c82829',
      orange: 'f5871f',
      yellow: 'eab700',
      green: '718c00',
      aqua: '3e999f',
      blue: '4271ae',
      purple: '8959a8',
    }
  
    def self.full_color_scheme(base)
      {
        background: base[:background],
        foreground: base[:foreground],

        brace: nil,
        bracket: nil,
        class_var: base[:red],  # this is just a guess
        comma: nil,
        comment: base[:comment],
        constant: base[:yellow],
        global_var: base[:red],  # this is just a guess
        identifier: nil,
        instance_var: nil,
        interpolation_mark: nil,
        keyword: base[:purple],
        lambda: nil,
        number: nil,
        operator: base[:aqua],
        paren: nil,
        period: nil,
        semicolon: nil,
        space: nil,
        string: base[:green],
        symbol: base[:green],
      }
    end
    
    Theme = full_color_scheme Base
  end
end

# Copyright (C) 2013 Chris Kempson
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.