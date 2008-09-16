#--
###############################################################################
#                                                                             #
# A component of cmess, the encoding tool-box.                                #
#                                                                             #
# Copyright (C) 2008 University of Cologne,                                   #
#                    Albertus-Magnus-Platz,                                   #
#                    50932 Cologne, Germany                                   #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
#                                                                             #
# cmess is free software; you can redistribute it and/or modify it under the  #
# terms of the GNU General Public License as published by the Free Software   #
# Foundation; either version 3 of the License, or (at your option) any later  #
# version.                                                                    #
#                                                                             #
# cmess is distributed in the hope that it will be useful, but WITHOUT ANY    #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS   #
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more       #
# details.                                                                    #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with cmess. If not, see <http://www.gnu.org/licenses/>.                     #
#                                                                             #
###############################################################################
#++

require 'iconv'
require 'cmess'

# Convert between bibliographic (and other) encodings.

module CMess::BConv

  extend self

  # our version ;-)
  VERSION = '0.0.1'

  INTERMEDIATE_ENCODING = 'utf-8'

  def encodings(chartab)
    chartab[chartab.keys.first].keys.map { |encoding|
      encoding.upcase unless encoding =~ /\A__/
    }.compact.sort
  end

  def convert(input, output, source_encoding, target_encoding, chartab)
    source_encoding.upcase!
    target_encoding.upcase!

    encodings = self.encodings(chartab)

    if encodings.include?(source_encoding)
      if encodings.include?(target_encoding)
        charmap = chartab.inject({}) { |hash, (code, map)|
          hash.update(map[source_encoding] => map[target_encoding].pack('U*'))
        }

        input.each_byte { |byte|
          output.print charmap[[byte]] || charmap[[byte, input.getc]]
        }
      else
        iconv = Iconv.new(target_encoding, INTERMEDIATE_ENCODING)

        charmap = chartab.inject({}) { |hash, (code, map)|
          hash.update(map[source_encoding] => [code.to_i(16)].pack('U*'))
        }

        input.each_byte { |byte|
          output.print iconv.iconv(charmap[[byte]] || charmap[[byte, input.getc]])
        }
      end
    else
      if encodings.include?(target_encoding)
        iconv = Iconv.new(INTERMEDIATE_ENCODING, source_encoding)

        charmap = chartab.inject({}) { |hash, (code, map)|
          hash.update(code.to_i(16) => map[target_encoding].pack('U*'))
        }

        input.each { |line|
          iconv.iconv(line).unpack('U*').each { |byte|
            output.print charmap[byte]
          }
        }
      else
        iconv = Iconv.new(target_encoding, source_encoding)

        input.each { |line|
          output.puts iconv.iconv(line)
        }
      end
    end
  end

end
