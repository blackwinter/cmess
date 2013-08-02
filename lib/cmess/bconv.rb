#--
###############################################################################
#                                                                             #
# A component of cmess, the encoding tool-box.                                #
#                                                                             #
# Copyright (C) 2008-2012 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Copyright (C) 2013 Jens Wille                                               #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@gmail.com>                                       #
#                                                                             #
# cmess is free software; you can redistribute it and/or modify it under the  #
# terms of the GNU Affero General Public License as published by the Free     #
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# cmess is distributed in the hope that it will be useful, but WITHOUT ANY    #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS   #
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for     #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU Affero General Public License    #
# along with cmess. If not, see <http://www.gnu.org/licenses/>.               #
#                                                                             #
###############################################################################
#++

require 'cmess'
require 'yaml'

# Convert between bibliographic (and other) encodings.

class CMess::BConv

  VERSION = '0.1.0'

  ENCODING = 'utf-8'

  DEFAULT_CHARTAB_FILE = File.join(CMess::DATA_DIR, 'chartab.yaml')

  class << self

    def convert(*args)
      new(*args).convert
    end

    def encodings(chartab = DEFAULT_CHARTAB_FILE)
      chartab = load_chartab(chartab)

      chartab[chartab.keys.first].keys.map { |encoding|
        encoding.upcase unless encoding =~ /\A__/
      }.compact.sort
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

  def initialize(options)
    @input, @output, _ = CMess.ensure_options!(options,
      :input, :output, :source_encoding, :target_encoding
    )

    @source_encoding = options[:source_encoding].upcase
    @target_encoding = options[:target_encoding].upcase

    @chartab   = self.class.load_chartab(options[:chartab] || DEFAULT_CHARTAB_FILE)
    @encodings = self.class.encodings(@chartab)

    [:source_encoding, :target_encoding].each { |key|
      instance_variable_set("@#{key}", encoding = options[key].upcase)
      instance_variable_set("@have_#{key}", encodings.include?(encoding))
    }
  end

  attr_reader :input, :output, :source_encoding, :target_encoding, :chartab, :encodings

  def convert
    source, target, out, charmap = source_encoding, target_encoding, output, {}

    if @have_source_encoding
      if @have_target_encoding
        chartab.each { |code, map|
          charmap[map[source]] = map[target].pack('U*')
        }

        input.each_byte { |char| out.print(map(char, charmap)) }
      else
        chartab.each { |code, map|
          charmap[map[source]] = [code.to_i(16)].pack('U*')
        }

        source = ENCODING

        input.each_byte { |char|
          out.print(encode(map(char, charmap), source, target))
        }
      end
    else
      if @have_target_encoding
        chartab.each { |code, map|
          charmap[code.to_i(16)] = map[target].pack('U*')
        }

        target = ENCODING

        input.each { |line|
          encode(line, source, target).unpack('U*').each { |char|
            out.print(charmap[char])
          }
        }
      else
        input.each { |line| out.print(encode(line, source, target)) }
      end
    end
  end

  private

  def encode(string, source, target)
    string.encode(target, source)
  rescue Encoding::UndefinedConversionError => err
    warn "ILLEGAL INPUT SEQUENCE: #{err.error_char}"
  end

  def map(char, charmap)
    unless map = charmap[[char]]
      unless map = charmap[[char, c = input.getc]]
        input.ungetc(c) if c
        map = ''
      end
    end

    map
  end

end
