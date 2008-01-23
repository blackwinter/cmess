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

$KCODE = 'u'

require 'iconv'
require 'forwardable'

# Outputs given string (or line), being encoded in target encoding, encoded in
# various test encodings, thus allowing to identify the (seemingly) correct
# encoding by visually comparing the input string with its desired appearance.
#
# In addition to that manual procedure, may be used to detect the encoding
# automatically. Works actually pretty good -- for the supported encodings
# (see Automatic for details).

module CMess::GuessEncoding

  # our version ;-)
  VERSION = '0.0.5'

  # Namespace for our encodings.
  module Encoding

    %w[
      UNKNOWN ASCII MACINTOSH
      ISO-8859-1 ISO-8859-2 ISO-8859-15
      CP1250 CP1251 CP1252 CP850 CP852 CP856
      UTF-8 UTF-16 UTF-16BE UTF-16LE UTF-32 UTF-32BE UTF-32LE
      UTF-7 UTF-EBCDIC SCSU BOCU-1
      ANSI_X3.4 EBCDIC-AT-DE EBCDIC-US EUC-JP KOI-8 MS-ANSI SHIFT-JIS
    ].each { |encoding|
      const = encoding.tr('-', '_').gsub(/\W/, '')
      const_set(const, encoding.freeze)
    }

  end

  module Manual

    extend self

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

  end

  # Tries to detect the encoding of a given input by applying several
  # heuristics to determine the <b>most likely</b> candidate. If no heuristic
  # catches on, resorts to Encoding::UNKNOWN.
  #
  # If a BOM is found, it may determine the encoding directly.
  class Automatic

    extend Forwardable

    def_delegators self, :encoding_guessers, :supported_encoding?,
                         :bom_guessers,      :supported_bom?

    include Encoding

    # Creates a converter for desired encoding (from UTF-8)
    ICONV_FOR = Hash.new { |h, k| h[k] = Iconv.new(k, UTF_8) }

    # Encodings to test statistically by TEST_CHARS
    TEST_ENCODINGS = [
      MACINTOSH,
      ISO_8859_1,
      ISO_8859_15,
      CP1252,
      CP850,
      MS_ANSI
    ]

    # Certain chars to test for in TEST_ENCODINGS
    TEST_CHARS = 'ÁÀÂÄÃÇÉÈÊËÍÌÎÏÑÓÒÔÖÚÙÛÜÆáàâäãçéèêëíìîïñóòôöúùûüæ'.
      split(//).inject(Hash.new { |h, k| h[k] = [] }) { |hash, char|
        TEST_ENCODINGS.each { |encoding|
          hash[encoding] += ICONV_FOR[encoding].iconv(char).unpack('C')
        }
        hash
      }

    # Relative count of TEST_CHARS must exceed this threshold to yield a match
    TEST_THRESHOLD = 0.0004

    @supported_encodings = []
    @encoding_guessers   = []
    @supported_boms      = []
    @bom_guessers        = []

    class << self

      attr_reader :supported_encodings, :encoding_guessers,
                  :supported_boms,      :bom_guessers

      def guess(input, chunk_size = nil, ignore_bom = false)
        new(input, chunk_size).guess(ignore_bom)
      end

      private

      def encoding(encoding, &condition_block)
        encoding_block = lambda {
          encoding if instance_eval(&condition_block)
        }

        encodings(encoding, &encoding_block)
      end

      def encodings(*encodings, &encoding_block)
        encodings.each { |encoding|
          @supported_encodings << encoding
          @encoding_guessers   << encoding_block
        }
      end

      def supported_encoding?(encoding)
        supported_encodings.include?(encoding)
      end

      def bom_encoding(encoding, &condition_block)
        encoding_block = lambda {
          encoding if instance_eval(&condition_block)
        }

        @supported_boms << encoding
        @bom_guessers   << encoding_block
      end

      def supported_bom?(encoding)
        supported_boms.include?(encoding)
      end

    end

    attr_reader :input, :chunk_size, :byte_count, :byte_total, :first_byte

    def initialize(input, chunk_size = nil)
      @input      = input
      @chunk_size = chunk_size
    end

    def guess(ignore_bom = false)
      return bom if bom && !ignore_bom

      while read
        encoding_guessers.each { |block|
          encoding = instance_eval(&block)
          return encoding if encoding && supported_encoding?(encoding)
        }
      end

      # nothing suitable found :-(
      UNKNOWN
    end

    def bom
      @bom ||= check_bom
    end

    private

    def eof?
      input.eof?
    end

    def check_bom
      return if eof?

      bom_guessers.each { |block|
        encoding = instance_eval(&block)
        return encoding if encoding && supported_bom?(encoding)

        # read bytes don't build a BOM, so rewind...
        input.rewind
      }

      # nothing suitable found :-(
      nil
    end

    def next_byte
      input.read(1).unpack('C').first
    end

    def starts_with?(*bytes)
      bytes.all? { |byte|
        next_byte == byte
      }
    end

    def next_one_of?(*bytes)
      bytes.include?(next_byte)
    end

    def read(chunk_size = chunk_size)
      # => initialize counters
      @byte_count ||= Hash.new(0)
      @byte_total ||= 0

      return if eof?

      bytes_before = @byte_total

      input.read(chunk_size).each_byte { |byte|
        @byte_count[byte] += 1
        @byte_total       += 1

        @first_byte ||= byte
      }

      @byte_total > bytes_before
    end

    def byte_count_sum(*bytes)
      bytes = *bytes  # treat arrays/ranges and lists alike
      bytes.inject(0) { |sum, n| sum + byte_count[n] }
    end

    def relative_byte_count(count)
      count.to_f / byte_total
    end

    ### Definition of guessing heuristics. Order matters!

    # ASCII, if all bytes are within the lower 128 bytes
    # (Unfortunately, we have to read the *whole* file to make that decision)
    encoding ASCII do
      eof? && byte_count_sum(0x0..0x7f) == byte_total
    end

    # UTF-16, if lots of NULL bytes present
    encodings UTF_16BE, UTF_16LE, UTF_16 do
      if relative_byte_count(byte_count[0]) > 0.25
        case first_byte
          when 0:   UTF_32
          when 254: UTF_16BE
          when 255: UTF_16LE
          else      UTF_16
        end
      end
    end

    # UTF-8, if number of escape-bytes and following bytes
    # is matching (cf. http://en.wikipedia.org/wiki/UTF-8)
    encoding UTF_8 do
      esc_bytes = byte_count_sum(0xc0..0xdf)     \
                  # => 110xxxxx 10xxxxxx
                + byte_count_sum(0xe0..0xef) * 2 \
                  # => 1110xxxx 10xxxxxx 10xxxxxx
                + byte_count_sum(0xf0..0xf7) * 3
                  # => 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
      fol_bytes = byte_count_sum(0x80..0xbf)
                  # => 10xxxxxx

      esc_bytes > 0 && esc_bytes == fol_bytes
    end

    # Analyse statistical appearance of German umlauts and other accented
    # letters (see TEST_CHARS)
    encodings *TEST_ENCODINGS do
      TEST_ENCODINGS.each { |encoding|
        break encoding if
          relative_byte_count(byte_count_sum(TEST_CHARS[encoding])) > TEST_THRESHOLD
      }
    end

    ### BOM detection. (cf. http://en.wikipedia.org/wiki/Byte-order_mark)

    bom_encoding UTF_8 do
      starts_with?(0xef, 0xbb, 0xbf)
    end

    bom_encoding UTF_16BE do
      starts_with?(0xfe, 0xff)
    end

    bom_encoding UTF_16LE do
      starts_with?(0xff, 0xfe)
    end

    bom_encoding UTF_32BE do
      starts_with?(0x00, 0x00, 0xfe, 0xff)
    end

    bom_encoding UTF_32LE do
      starts_with?(0xff, 0xfe, 0x00, 0x00)
    end

    bom_encoding SCSU do
      starts_with?(0x0e, 0xfe, 0xff)
    end

    bom_encoding UTF_7 do
      starts_with?(0x2b, 0x2f, 0x76) && next_one_of?(0x38, 0x39, 0x2b, 0x2f)
    end

    bom_encoding UTF_EBCDIC do
      starts_with?(0xdd, 0x73, 0x66, 0x73)
    end

    bom_encoding BOCU_1 do
      starts_with?(0xfb, 0xee, 0x28)
    end

  end

end
