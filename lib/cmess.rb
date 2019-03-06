# frozen_string_literal: true

#--
###############################################################################
#                                                                             #
# cmess -- Assist with handling messed up encodings                           #
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

require_relative 'cmess/version'

# CMess - Assist with handling messed up encodings. See README for more information.
module CMess
  DATA_DIR = ENV['CMESS_DATA'] || File.expand_path('../data', __dir__)

  class << self
    def ensure_options!(options, *required)
      values = []
      missing = []

      required.each do |key|
        value = options[key]
        value.nil? ? missing << key : values << value
      end

      if missing.empty?
        values
      else
        raise(ArgumentError, "required options missing: #{missing.join(', ')}", caller(1))
      end
    end
  end
end
