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

require 'cmess' unless Object.const_defined?(:CMess)

# Allows to guess an input's encoding either manually or automatically.
# Works actually pretty good -- for the supported encodings. See Manual
# and Automatic for details.

module CMess::GuessEncoding
  VERSION = '0.2.0'

  class << self
    def manual(*args)
      Manual.display(*args)
    end

    alias display manual

    def automatic(*args)
      Automatic.guess(*args)
    end

    alias guess automatic
  end
end

require_relative 'guess_encoding/encoding'
require_relative 'guess_encoding/manual'
require_relative 'guess_encoding/automatic'
