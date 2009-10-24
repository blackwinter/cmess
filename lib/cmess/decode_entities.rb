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
require 'cmess'

require 'rubygems'
require 'htmlentities'

module CMess::DecodeEntities

  extend self

  # our version ;-)
  VERSION = '0.0.3'

  # HTMLEntities requires UTF-8
  INTERMEDIATE_ENCODING = 'utf-8'

  ICONV_DUMMY = begin
    dummy = Object.new

    def dummy.iconv(string)
      string
    end

    dummy
  end

  def decode(input, output, source_encoding, target_encoding = nil)
    target_encoding ||= source_encoding

    iconv_in  = source_encoding != INTERMEDIATE_ENCODING ?
      Iconv.new(INTERMEDIATE_ENCODING, source_encoding) : ICONV_DUMMY

    iconv_out = target_encoding != INTERMEDIATE_ENCODING ?
      Iconv.new(target_encoding, INTERMEDIATE_ENCODING) : ICONV_DUMMY

    html_entities = HTMLEntities.new

    input.each { |line|
      output.puts iconv_out.iconv(html_entities.decode(iconv_in.iconv(line)))
    }
  end

end
