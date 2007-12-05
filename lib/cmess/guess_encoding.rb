#--
###############################################################################
#                                                                             #
# A component of cmess, the encoding tool-box.                                #
#                                                                             #
# Copyright (C) 2007 University of Cologne,                                   #
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

# Outputs given string (or line), being encoded in target encoding, encoded in
# various test encodings, thus allowing to identify the (seemingly) correct
# encoding by visually comparing the input string with its desired appearance.

module CMess::GuessEncoding

  extend self

  # our version ;-)
  VERSION = '0.0.3'

  # default encodings to try
  ENCODINGS = %w[
    ISO-8859-1
    ISO-8859-2
    ISO-8859-15
    CP1250
    CP1251
    CP1252
    CP850
    CP852
    CP856
    UTF-8
  ]

  # likely candidates to suggest to the user
  CANDIDATES = %w[
    ANSI_X3.4
    EBCDIC-AT-DE
    EBCDIC-US
    EUC-JP
    KOI-8
    MACINTOSH
    MS-ANSI
    SHIFT-JIS
    UTF-7
    UTF-16
    UTF-16BE
    UTF-16LE
    UTF-32
    UTF-32BE
    UTF-32LE
  ]

  def display(input, target_encoding, encodings = nil, additional_encodings = [])
    target = target_encoding

    encodings = (encodings || ENCODINGS) + additional_encodings
    encodings = encodings.reverse.uniq.reverse     # uniq with additional encodings
                                                   # staying at the end
    encodings = [target] + (encodings - [target])  # move target encoding to front

    max_length = encodings.map { |encoding| encoding.length }.max

    encodings.each { |encoding|
      converted = begin
        Iconv.conv(target, encoding, input)
      rescue Iconv::IllegalSequence => err
        "ILLEGAL INPUT SEQUENCE: #{err}"
      rescue Iconv::InvalidEncoding
        if encoding == target
          abort "Invalid encoding: #{encoding}"
        else
          "INVALID ENCODING!"
        end
      end

      puts "%-#{max_length}s : %s" % [encoding, converted]
    }
  end

end
