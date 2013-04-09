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

# Find (and possibly repair) doubly encoded characters. Here's how it's done:
#
# Treats characters encoded in target encoding as if they were encoded in
# source encoding, converts them to target encoding and "grep"s for lines
# containing those doubly encoded characters; if asked to repair doubly
# encoded characters, substitutes them with their original character.

module CMess::Cinderella

  extend self

  VERSION = '0.0.5'

  DEFAULT_CSETS_DIR = File.join(CMess::DATA_DIR, 'csets')

  def pick(options)
    CMess.ensure_options!(options,
      :input, :pot, :crop, :source_encoding, :target_encoding, :chars
    )

    encoded = {}
    iconv = Iconv.new(*options.values_at(:target_encoding, :source_encoding))

    options[:chars].each { |char|
      begin
        encoded[iconv.iconv(char)] = char
      rescue Iconv::IllegalSequence
      end
    }

    regexp = Regexp.union(*encoded.keys)
    pot, crop, repair = options.values_at(:pot, :crop, :repair)

    options[:input].each { |line|
      if out = line =~ regexp ? crop : pot
        line.gsub!(regexp) { |m| encoded[m] } if repair
        out.puts(line)
      end
    }
  end

end
