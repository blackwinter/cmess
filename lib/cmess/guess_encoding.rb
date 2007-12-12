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
#
# In addition to that manual procedure, may be used to detect the encoding
# automatically. Works actually pretty good -- for the supported encodings
# (see Guesser for details).

module CMess::GuessEncoding

  extend self

  # our version ;-)
  VERSION = '0.0.4'

  # Namespace for our encodings.
  module Encoding

    %w[
      UNKNOWN ASCII MACINTOSH
      ISO-8859-1 ISO-8859-2 ISO-8859-15
      CP1250 CP1251 CP1252 CP850 CP852 CP856
      UTF-7 UTF-8 UTF-16 UTF-16BE UTF-16LE UTF-32 UTF-32BE UTF-32LE
      ANSI_X3.4 EBCDIC-AT-DE EBCDIC-US EUC-JP KOI-8 MS-ANSI SHIFT-JIS
    ].each { |encoding|
      const = encoding.tr('-', '_').gsub(/\W/, '')
      const_set(const, encoding.freeze)
    }

  end

  include Encoding

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

  def guess(input)
    Guesser.new(input).guess
  end

  # Tries to detect the encoding of a given input by applying several
  # heuristics to determine the <b>most likely</b> candidate. If no heuristic
  # catches on, resorts to Encoding::UNKNOWN.
  class Guesser

    include Encoding

    @supported_encodings = []
    @encoding_guessers   = []

    class << self

      attr_reader :supported_encodings, :encoding_guessers

      def register_single_encoding(encoding, *aliases, &condition_block)
        encoding_block = lambda {
          encoding if instance_eval(&condition_block)
        }

        register_multiple_encodings(encoding, *aliases, &encoding_block)
      end

      def register_multiple_encodings(*encodings, &encoding_block)
        encodings.each { |encoding|
          @supported_encodings << encoding
          @encoding_guessers   << encoding_block
        }
      end

      def supported_encoding?(encoding)
        supported_encodings.include?(encoding)
      end

    end

    ### Definition of guessing heuristics. Order matters!

    # ASCII, if all bytes are within the lower 128 bytes
    register_single_encoding(ASCII) {
      byte_count_sum(0x0..0x7f) == byte_total
    }

    # UTF-16, if lots of NULL bytes present (ignore first two endianness bytes)
    register_multiple_encodings(UTF_16BE, UTF_16LE, UTF_16) {
      if byte_count[0].to_f / (byte_total - 2) > 0.45
      # relative_byte_count(byte_count[0]) > 0.45 ???
        case first_byte
          when 254: UTF_16BE
          when 255: UTF_16LE
          else      UTF_16
        end
      end
    }

    # UTF-8, if number of escape-bytes and following bytes
    # is matching (cf. http://en.wikipedia.org/wiki/UTF-8)
    register_single_encoding(UTF_8) {
      esc_bytes = byte_count_sum(0xc0..0xdf)     \
                  # => 110xxxxx 10xxxxxx
                + byte_count_sum(0xe0..0xef) * 2 \
                  # => 1110xxxx 10xxxxxx 10xxxxxx
                + byte_count_sum(0xf0..0xf7) * 3
                  # => 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
      fol_bytes = byte_count_sum(0x80..0xbf)
                  # => 10xxxxxx

      esc_bytes > 0 && esc_bytes == fol_bytes
    }

    # Analyse statistical appearance of German umlauts (=> ÄäÖöÜüß)
    register_multiple_encodings(MACINTOSH, ISO_8859_1) {
      {
        MACINTOSH  => [0x80, 0x8a, 0x85, 0x9a, 0x86, 0x9f, 0xa7],
        ISO_8859_1 => [0xc4, 0xe4, 0xd6, 0xf6, 0xdc, 0xfc, 0xdf]
      }.each { |encoding, umlauts|
        break encoding if relative_byte_count(byte_count_sum(umlauts)) > 0.001
      }
    }

    ### END

    extend Forwardable

    def_delegators :@klass, :encoding_guessers, :supported_encoding?

    attr_reader :byte_count, :byte_total, :first_byte

    def initialize(input)
      # => initialize counters
      @byte_count = Hash.new(0)
      @byte_total = 0
      @first_byte = nil

      # => statistical analysis
      input.each_byte { |byte|
        @byte_count[byte] += 1
        @byte_total       += 1
        @first_byte ||= byte
      }

      @klass = self.class
    end

    def guess
      encoding_guessers.each { |block|
        encoding = instance_eval(&block)
        return encoding if encoding && supported_encoding?(encoding)
      }

      # nothing suitable found :-(
      UNKNOWN
    end

    private

    def byte_count_sum(*bytes)
      bytes = *bytes  # treat arrays/ranges and lists alike
      bytes.inject(0) { |sum, n| sum + byte_count[n] }
    end

    def relative_byte_count(count)
      count.to_f / byte_total
    end

  end

end
