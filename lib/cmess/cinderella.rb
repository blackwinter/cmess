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
# Copyright (C) 2013-2016 Jens Wille                                          #
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

require 'cmess' unless Object.const_defined?(:CMess)

# Find (and possibly repair) doubly encoded characters. Here's how it's done:
#
# Treats characters encoded in target encoding as if they were encoded in
# source encoding, converts them to target encoding and "grep"s for lines
# containing those doubly encoded characters; if asked to repair doubly
# encoded characters, substitutes them with their original character.

module CMess::Cinderella
  extend self

  VERSION = '0.1.1'

  DEFAULT_CSETS_DIR = File.join(CMess::DATA_DIR, 'csets')

  def pick(options)
    input, source, target, chars = CMess.ensure_options!(options,
                                                         :input, :source_encoding, :target_encoding, :chars)

    pot, crop, repair = options.values_at(:pot, :crop, :repair)

    encoded = {}
    chars.each { |char| encoded[encode(char, source, target)] = char }

    regexp = Regexp.union(*encoded.keys)

    input.each do |line|
      (out = line&.match?(regexp) ? crop : pot) || next

      line.gsub!(regexp, encoded) if repair
      out.puts(line)
    end
  end

  private

  def encode(string, source, target)
    string.encode(target, source)
  rescue Encoding::UndefinedConversionError
  end
end
