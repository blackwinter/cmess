#--
###############################################################################
#                                                                             #
# A component of cmess, the encoding tool-box.                                #
#                                                                             #
# Copyright (C) 2007-2008 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50932 Cologne, Germany                              #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
#                                                                             #
# Contributors:                                                               #
#     John Vorhauer <john@vorhauer.de> (idea and original implementation      #
#                                       for automatic encoding detection)     #
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

# Outputs given string (or line), being encoded in target encoding, encoded in
# various test encodings, thus allowing to identify the (seemingly) correct
# encoding by visually comparing the input string with its desired appearance.

module CMess::GuessEncoding::Manual

  extend self

  include CMess::GuessEncoding::Encoding

  # default encodings to try
  ENCODINGS = [
    ISO_8859_1,
    ISO_8859_2,
    ISO_8859_15,
    CP1250,
    CP1251,
    CP1252,
    CP850,
    CP852,
    CP856,
    UTF_8
  ]

  # likely candidates to suggest to the user
  CANDIDATES = [
    ANSI_X34,
    EBCDIC_AT_DE,
    EBCDIC_US,
    EUC_JP,
    KOI_8,
    MACINTOSH,
    MS_ANSI,
    SHIFT_JIS,
    UTF_7,
    UTF_16,
    UTF_16BE,
    UTF_16LE,
    UTF_32,
    UTF_32BE,
    UTF_32LE
  ]

  def display(input, target_encoding, encodings = nil, additional_encodings = [])
    target = target_encoding

    encodings = (encodings || ENCODINGS) + additional_encodings
    encodings = encodings.include?('__ALL__') ? all_encodings :
      encodings.reverse.uniq.reverse  # uniq with additional encodings
                                      # staying at the end

    # move target encoding to front
    encodings = [target] + (encodings - [target])

    max_length = encodings.map { |encoding| encoding.length }.max

    encodings.each { |encoding|
      converted = begin
        Iconv.conv(target, encoding, input)
      rescue Iconv::IllegalSequence, Iconv::InvalidCharacter => err
        "ILLEGAL INPUT SEQUENCE: #{err}"
      rescue Iconv::InvalidEncoding
        if encoding == target
          raise ArgumentError, "invalid encoding: #{encoding}"
        else
          "INVALID ENCODING!"
        end
      end

      puts "%-#{max_length}s : %s" % [encoding, converted]
    }
  end

end
