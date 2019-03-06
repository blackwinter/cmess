# frozen_string_literal: true

# rubocop:disable Naming/MethodName

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
# Contributors:                                                               #
#     John Vorhauer <john@vorhauer.de> (idea and original implementation      #
#                                       for automatic encoding detection)     #
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

require 'stringio'
require 'forwardable'
require 'safe_yaml/load'

# Tries to detect the encoding of a given input by applying several
# heuristics to determine the <b>most likely</b> candidate. If no
# heuristic catches on, resorts to Encoding::UNKNOWN.
#
# If a BOM is found, it may determine the encoding directly.
#
# For supported encodings see EncodingGuessers and BOMGuessers.

class CMess::GuessEncoding::Automatic
  extend Forwardable

  def_delegators self, :encoding_guessers, :supported_encoding?,
                 :bom_guessers, :supported_bom?

  include CMess::GuessEncoding::Encoding

  # Single-byte encodings to test statistically by TEST_CHARS.
  TEST_ENCODINGS = [
    MACINTOSH,
    ISO_8859_1,
    ISO_8859_2,
    ISO_8859_3,
    ISO_8859_4,
    ISO_8859_5,
    ISO_8859_6,
    ISO_8859_7,
    ISO_8859_8,
    ISO_8859_9,
    ISO_8859_10,
    ISO_8859_11,
    ISO_8859_13,
    ISO_8859_14,
    ISO_8859_15,
    ISO_8859_16,
    CP1252,
    CP850,
    MS_ANSI
  ].freeze

  # Certain (non-ASCII) chars to test for in TEST_ENCODINGS.
  CHARS_TO_TEST =
    '€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂ' \
    'ÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ'
    .chars.to_a

  # Map TEST_ENCODINGS to respectively encoded CHARS_TO_TEST.
  TEST_CHARS = Hash.new do |h, k|
    e = self[k]
    f = UTF_8
    TEST_ENCODINGS << e unless TEST_ENCODINGS.include?(e)
    h[e] = CHARS_TO_TEST.flat_map { |c| c.encode(e, f).unpack('C') }
  end.update(SafeYAML.load_file(File.join(CMess::DATA_DIR, 'test_chars.yaml')))

  # Relative count of TEST_CHARS must exceed this threshold to yield
  # a direct match.
  TEST_THRESHOLD_DIRECT = 0.1

  # Relative count of TEST_CHARS must exceed this threshold to yield
  # an approximate match.
  TEST_THRESHOLD_APPROX = 0.0004

  # Pattern for method names in EncodingGuessers and BOMGuessers.
  GUESS_METHOD_RE = /\A((?:bom_)?encoding)_\d+_(.+)\z/.freeze

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

    def supported_encoding?(encoding)
      supported_encodings.include?(encoding)
    end

    def supported_bom?(encoding)
      supported_boms.include?(encoding)
    end

    private

    def encoding(*encodings, &block)
      encodings.flatten.each do |encoding|
        unless supported_encoding?(encoding)
          supported_encodings << encoding
          encoding_guessers   << block
        end
      end
    end

    def bom_encoding(encoding, &block)
      unless supported_bom?(encoding)
        supported_boms << encoding
        bom_guessers   << ->(*) { encoding if instance_eval(&block) }
      end
    end
  end

  def initialize(input, chunk_size = nil)
    @input =
      case input
      when IO     then
        input
      when String then
        StringIO.new(input)
      else
        raise ArgumentError, "don't know how to handle input of type #{input.class}"
      end

    @chunk_size = chunk_size
  end

  attr_reader :input, :chunk_size, :byte_count, :byte_total, :first_byte

  def guess(ignore_bom = false)
    return bom if bom && !ignore_bom

    while read
      encoding_guessers.each do |block|
        if (encoding = instance_eval(&block)) && supported_encoding?(encoding)
          return encoding
        end
      end
    end

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

    # prevent "Illegal seek" error inside a pipe
    begin
      input.pos
    rescue Errno::ESPIPE
      return
    end

    bom_guessers.each do |block|
      if (encoding = instance_eval(&block)) && supported_encoding?(encoding)
        return encoding
      else
        input.rewind
      end
    end

    nil
  end

  def next_byte
    input.read(1).unpack1('C')
  end

  def starts_with?(*bytes)
    bytes.all? { |byte| next_byte == byte }
  end

  def next_one_of?(*bytes)
    bytes.include?(next_byte)
  end

  def read(chunk_size = @chunk_size)
    @byte_count ||= Hash.new(0)
    @byte_total ||= 0

    return if eof?

    bytes_before = @byte_total

    input.read(chunk_size).each_byte do |byte|
      @byte_count[byte] += 1
      @byte_total       += 1

      @first_byte ||= byte
    end

    @byte_total > bytes_before
  end

  def byte_count_sum(bytes)
    Array(bytes).inject(0) { |sum, n| sum + byte_count[n] }
  end

  def relative_byte_count(count)
    count.to_f / byte_total
  end

  # Definition of guessing heuristics. Order matters!

  module EncodingGuessers
    include CMess::GuessEncoding::Encoding

    # ASCII[http://en.wikipedia.org/wiki/ASCII], if all bytes are
    # within the lower 128 bytes. Unfortunately, we have to read
    # the *whole* file to make that decision.
    def encoding_01_ASCII
      ASCII if eof? && byte_count_sum(0x00..0x7f) == byte_total
    end

    # UTF-16[http://en.wikipedia.org/wiki/UTF-16] /
    # UTF-32[http://en.wikipedia.org/wiki/UTF-32], if lots of
    # NULL[http://en.wikipedia.org/wiki/Null_character] bytes present.
    def encoding_02_UTF_32_and_UTF_16BE_and_UTF_16LE_and_UTF_16
      if relative_byte_count(byte_count[0]) > 0.25
        case first_byte
        when 0x00 then UTF_32
        when 0xfe then UTF_16BE
        when 0xff then UTF_16LE
        else UTF_16
        end
      end
    end

    # UTF-8[http://en.wikipedia.org/wiki/UTF-8], if number of escape-bytes
    # and following bytes is matching.
    def encoding_03_UTF_8
      esc_bytes = byte_count_sum(0xc0..0xdf)     +
                  # => 110xxxxx 10xxxxxx
                  byte_count_sum(0xe0..0xef) * 2 +
                  # => 1110xxxx 10xxxxxx 10xxxxxx
                  byte_count_sum(0xf0..0xf7) * 3
      # => 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx

      UTF_8 if esc_bytes.positive? && esc_bytes == byte_count_sum(0x80..0xbf)
    end

    # TEST_ENCODINGS, if frequency of TEST_CHARS exceeds TEST_THRESHOLD_DIRECT
    # (direct match) or TEST_THRESHOLD_APPROX (approximate match).
    def encoding_04_TEST_ENCODINGS
      ratios = {}

      TEST_ENCODINGS.find(lambda {
        ratio, encoding = ratios.max
        encoding if ratio >= TEST_THRESHOLD_APPROX
      }) do |encoding|
        ratio = relative_byte_count(byte_count_sum(TEST_CHARS[encoding]))
        ratio >= TEST_THRESHOLD_DIRECT || (ratios[ratio] ||= encoding; false)
      end
    end
  end

  # BOM[http://en.wikipedia.org/wiki/Byte_order_mark] detection.

  module BOMGuessers
    # UTF-8[http://en.wikipedia.org/wiki/UTF-8]
    def bom_encoding_01_UTF_8
      starts_with?(0xef, 0xbb, 0xbf)
    end

    # UTF-16[http://en.wikipedia.org/wiki/UTF-16] (Big Endian)
    def bom_encoding_02_UTF_16BE
      starts_with?(0xfe, 0xff)
    end

    # UTF-16[http://en.wikipedia.org/wiki/UTF-16] (Little Endian)
    def bom_encoding_03_UTF_16LE
      starts_with?(0xff, 0xfe)
    end

    # UTF-32[http://en.wikipedia.org/wiki/UTF-32] (Big Endian)
    def bom_encoding_04_UTF_32BE
      starts_with?(0x00, 0x00, 0xfe, 0xff)
    end

    # UTF-32[http://en.wikipedia.org/wiki/UTF-32] (Little Endian)
    def bom_encoding_05_UTF_32LE
      starts_with?(0xff, 0xfe, 0x00, 0x00)
    end

    # SCSU[http://en.wikipedia.org/wiki/Standard_Compression_Scheme_for_Unicode]
    def bom_encoding_06_SCSU
      starts_with?(0x0e, 0xfe, 0xff)
    end

    # UTF-7[http://en.wikipedia.org/wiki/UTF-7]
    def bom_encoding_07_UTF_7
      starts_with?(0x2b, 0x2f, 0x76) && next_one_of?(0x38, 0x39, 0x2b, 0x2f)
    end

    # UTF-1[http://en.wikipedia.org/wiki/UTF-1]
    def bom_encoding_08_UTF_1
      starts_with?(0xf7, 0x64, 0x4c)
    end

    # UTF-EBCDIC[http://en.wikipedia.org/wiki/UTF-EBCDIC]
    def bom_encoding_09_UTF_EBCDIC
      starts_with?(0xdd, 0x73, 0x66, 0x73)
    end

    # BOCU-1[http://en.wikipedia.org/wiki/BOCU-1]
    def bom_encoding_10_BOCU_1
      starts_with?(0xfb, 0xee, 0x28)
    end

    # GB-18030[http://en.wikipedia.org/wiki/GB-18030]
    def bom_encoding_11_GB_18030
      starts_with?(0x84, 0x31, 0x95, 0x33)
    end
  end

  [EncodingGuessers, BOMGuessers].each do |mod|
    include mod

    mod.instance_methods(false).sort.each do |method|
      next unless method =~ GUESS_METHOD_RE

      name = Regexp.last_match(1)
      list = Regexp.last_match(2).split('_and_')

      send(name, *list.map { |encoding| const_get(encoding) }) { send(method) }
    end
  end
end
# rubocop:enable Naming/MethodName
