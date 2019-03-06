# frozen_string_literal: true

#--
###############################################################################
#                                                                             #
# A component of cmess, the encoding tool-box.                                #
#                                                                             #
# Copyright (C) 2008-2012 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Copyright (C) 2013-2014 Jens Wille                                          #
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

require 'safe_yaml/load'

require 'cmess' unless Object.const_defined?(:CMess)

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

      chartab[chartab.keys.first].keys.map do |encoding|
        encoding.upcase unless encoding.start_with?('__')
      end.compact.sort
    end

    def load_chartab(chartab)
      case chartab
      when Hash
        chartab
      when String
        raise "chartab file not found: #{chartab}" unless File.readable?(chartab)

        SafeYAML.load_file(chartab)
      else
        raise ArgumentError, "invalid chartab of type #{chartab.class}"
      end
    end
  end

  def initialize(options)
    @input, @output, = CMess.ensure_options!(options,
                                             :input, :output, :source_encoding, :target_encoding)

    @chartab   = self.class.load_chartab(options[:chartab] || DEFAULT_CHARTAB_FILE)
    @encodings = self.class.encodings(@chartab)

    %i[source_encoding target_encoding].each do |key|
      instance_variable_set("@#{key}", encoding = options[key].upcase)
      instance_variable_set("@have_#{key}", encodings.include?(encoding))
    end
  end

  attr_reader :input, :output, :source_encoding, :target_encoding, :chartab, :encodings

  def convert
    # TODO: Refactor  
    source = source_encoding
    target = target_encoding
    out = output
    charmap = {}

    if @have_source_encoding && @have_target_encoding
      chartab.each do |_code, map|
        charmap[map[source]] = map[target].pack('U*')
      end

      input.each_byte { |char| out.print(map(char, charmap)) }

    elsif @have_source_encoding
      chartab.each do |code, map|
        charmap[map[source]] = [code.to_i(16)].pack('U*')
      end

      source = ENCODING

      input.each_byte do |char|
        out.print(encode(map(char, charmap), source, target))
      end

    elsif @have_target_encoding
      chartab.each do |code, map|
        charmap[code.to_i(16)] = map[target].pack('U*')
      end

      target = ENCODING

      input.each do |line|
        encode(line, source, target).unpack('U*').each do |char|
          out.print(charmap[char])
        end
      end
    else
      input.each { |line| out.print(encode(line, source, target)) }
    end
  end

  private

  def encode(string, source, target)
    string.encode(target, source)
  rescue Encoding::UndefinedConversionError => err
    warn "ILLEGAL INPUT SEQUENCE: #{err.error_char}"
  end

  def map(char, charmap)
    # TODO: refactor (too many unlesses here)
    unless map = charmap[[char]]
      unless map = charmap[[char, c = input.getc]]
        input.ungetc(c) if c
        map = ''
      end
    end

    map
  end

  # def map_refactor(char, charmap)
  #   # if map = charmap[[char]] fails do
  #   # if map = charmap[[char, c = input.getc]] fails do
  #   # reset input (which is what?)
  #   # set map to ''
  #   # return map
  # end
end
