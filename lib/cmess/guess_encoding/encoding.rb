# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName

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

# Namespace for our encodings.

module CMess::GuessEncoding::Encoding
  extend self

  def all_encodings
    if const_defined?(:ALL_ENCODINGS)
      ALL_ENCODINGS
    else
      const_set(:ALL_ENCODINGS, get_all_encodings)
    end
  end

  def [](encoding)
    get_or_set_encoding_const(encoding)
  end

  private_class_method :included

  private

  def get_all_encodings
    Encoding.name_list.map { |encoding| get_or_set_encoding_const(encoding) }
  end

  def const_name_for(encoding)
    encoding.tr('-', '_').gsub(/\W/, '').sub(/\A\d/, 'ENC_\&').upcase
  end

  def set_encoding_const(encoding, const = const_name_for(encoding))
    const_set(const, encoding.freeze)
  end

  def get_or_set_encoding_const(encoding)
    if const_defined?(const = const_name_for(encoding))
      const_get(const)
    else
      set_encoding_const(encoding, const)
    end
  end

  %w[
    UNKNOWN ASCII MACINTOSH
    ISO-8859-1 ISO-8859-2 ISO-8859-3 ISO-8859-4 ISO-8859-5
    ISO-8859-6 ISO-8859-7 ISO-8859-8 ISO-8859-9 ISO-8859-10
    ISO-8859-11 ISO-8859-13 ISO-8859-14 ISO-8859-15 ISO-8859-16
    CP1250 CP1251 CP1252 CP850 CP852 CP856
    UTF-8 UTF-16 UTF-16BE UTF-16LE UTF-32 UTF-32BE UTF-32LE
    UTF-7 UTF-1 UTF-EBCDIC SCSU BOCU-1 GB-18030
    ANSI_X3.4 EBCDIC-AT-DE EBCDIC-US EUC-JP KOI-8 MS-ANSI SHIFT-JIS
  ].each { |encoding| set_encoding_const(encoding) }

  def self.included(base)
    base.extend(self)
  end
end
# rubocop:enable Naming/AccessorMethodName
