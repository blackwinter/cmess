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

require 'htmlentities'

require 'cmess' unless Object.const_defined?(:CMess)

module CMess::DecodeEntities
  extend self

  VERSION = '0.1.0'

  # HTMLEntities requires UTF-8
  ENCODING = 'UTF-8'

  DEFAULT_FLAVOUR = 'xml-safe'

  def decode(options)
    input, output, source = CMess.ensure_options!(options,
                                                  :input, :output, :source_encoding)

    target = options[:target_encoding] || source
    entities = HTMLEntities.new(options[:flavour] || DEFAULT_FLAVOUR)
    encoding = ENCODING

    skip_source = source == encoding
    skip_target = target == encoding

    input.each do |line|
      line = encode(line, source, encoding) unless skip_source
      line = entities.decode(line)
      line = encode(line, encoding, target) unless skip_target

      output.puts(line)
    end
  end

  private

  def encode(string, source, target)
    string.encode(target, source)
  end
end

class HTMLEntities # :nodoc:
  FLAVORS << 'xml-safe'
  MAPPINGS['xml-safe'] = MAPPINGS['xhtml1'].dup
  %w[amp apos gt lt quot].each { |key| MAPPINGS['xml-safe'].delete(key) }
end
