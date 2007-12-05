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

module CMess::CLI

    def ensure_readable(file)
      abort "Can't find input file: #{file}" unless File.readable?(file)
    end

    def ensure_directory(dir)
      abort "Directory not found: #{dir}" unless File.directory?(dir)
    end

    def open_file_in_place(file)
      ensure_readable(file)
      [File.readlines(file), File.open(file, 'w')]
    end

    def open_file_or_std(file, mode = 'r')
      if file == '-'
        case mode
          when 'r': STDIN
          when 'w': STDOUT
          when 'a': STDERR
          else      raise ArgumentError, "don't know how to handle mode '#{mode}'"
        end
      else
        ensure_readable(file) unless mode == 'w'
        File.open(file, mode)
      end
    end

    def determine_system_encoding
      ENV['SYSTEM_ENCODING']   ||
      ENV['LANG'][/\.(.*)/, 1] ||
      system_encoding_not_found
    end

    def system_encoding_not_found
      not_found = lambda {
        abort <<-EOT
Your system's encoding couldn't be determined automatically -- please specify it
explicitly via the SYSTEM_ENCODING environment variable or via the '-t' option.
        EOT
      }

      def not_found.to_s
        'NOT FOUND'
      end

      not_found
    end

  end
