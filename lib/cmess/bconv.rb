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

require 'yaml'
require 'iconv'
require 'cmess'

# Convert between bibliographic (and other) encodings.

class CMess::BConv

  # our version ;-)
  VERSION = '0.0.2'

  INTERMEDIATE_ENCODING = 'utf-8'

  DEFAULT_CHARTAB_FILE = File.join(CMess::DATA_DIR, 'chartab.yaml')

  class << self

    def encodings(chartab = DEFAULT_CHARTAB_FILE)
      chartab = load_chartab(chartab)

      chartab[chartab.keys.first].keys.map { |encoding|
        encoding.upcase unless encoding =~ /\A__/
      }.compact.sort
    end

    def convert(*args)
      new(*args).convert
    end

    def load_chartab(chartab)
      case chartab
        when Hash
          chartab
        when String
          raise "chartab file not found: #{chartab}" unless File.readable?(chartab)
          YAML.load_file(chartab)
        else
          raise ArgumentError, "invalid chartab of type #{chartab.class}"
      end
    end

  end

  attr_reader :input, :output, :source_encoding, :target_encoding, :chartab, :encodings

  def initialize(input, output, source_encoding, target_encoding, chartab = DEFAULT_CHARTAB_FILE)
    @input, @output = input, output

    @source_encoding = source_encoding.upcase
    @target_encoding = target_encoding.upcase

    @chartab = self.class.load_chartab(chartab)
    @encodings = self.class.encodings(@chartab)
  end

  def encoding?(encoding)
    encodings.include?(encoding)
  end

  def convert
    if encoding?(source_encoding)
      if encoding?(target_encoding)
        @charmap = chartab.inject({}) { |hash, (code, map)|
          hash.update(map[source_encoding] => map[target_encoding].pack('U*'))
        }

        input.each_byte { |char|
          output.print map(char)
        }
      else
        iconv = iconv_to

        @charmap = chartab.inject({}) { |hash, (code, map)|
          hash.update(map[source_encoding] => [code.to_i(16)].pack('U*'))
        }

        input.each_byte { |char|
          output.print iconv.iconv(map(char))
        }
      end
    else
      if encoding?(target_encoding)
        iconv = iconv_from

        charmap = chartab.inject({}) { |hash, (code, map)|
          hash.update(code.to_i(16) => map[target_encoding].pack('U*'))
        }

        input.each { |line|
          iconv.iconv(line).unpack('U*').each { |char|
            output.print charmap[char]
          }
        }
      else
        iconv = iconv_from_to

        input.each { |line|
          output.puts iconv.iconv(line)
        }
      end
    end
  end

  private

  def iconv_from_to(from = source_encoding, to = target_encoding)
    iconv = begin
      Iconv.new(to, from)
    rescue Iconv::InvalidEncoding
      raise ArgumentError, "invalid encoding: source encoding = #{from}, target encoding = #{to}"
    end

    def iconv.iconv(*args)
      super
    rescue Iconv::IllegalSequence, Iconv::InvalidCharacter => err
      warn "ILLEGAL INPUT SEQUENCE: #{err}"; ''
    end

    iconv
  end

  def iconv_from(from = source_encoding)
    iconv_from_to(from, INTERMEDIATE_ENCODING)
  end

  def iconv_to(to = target_encoding)
    iconv_from_to(INTERMEDIATE_ENCODING, to)
  end

  def map(char, charmap = @charmap)
    unless map = charmap[[char]]
      unless map = charmap[[char, c = input.getc]]
        input.ungetc(c) if c
        map = ''
      end
    end

    map
  end

end
