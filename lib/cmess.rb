#--
###############################################################################
#                                                                             #
# cmess -- Assist with handling messed up encodings                           #
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

require 'cmess/version'

# See README for more information.

module CMess

  autoload :BConv,          'cmess/bconv'
  autoload :Cinderella,     'cmess/cinderella'
  autoload :CLI,            'cmess/cli'
  autoload :DecodeEntities, 'cmess/decode_entities'
  autoload :GuessEncoding,  'cmess/guess_encoding'

  DATA_DIR = ENV['CMESS_DATA'] || File.expand_path('../../data', __FILE__)

  class << self

    def ensure_options!(options, *required)
      values = options.values_at(*required)

      missing = values.select { |value| value.nil? }
      return values if missing.empty?

      msg = "required options missing: #{missing.join(', ')}"
      raise ArgumentError, msg, caller(1)
    end

  end

end
