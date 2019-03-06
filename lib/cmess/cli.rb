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

require 'optparse'
require 'tempfile'
require 'nuggets/env/user_encoding'
require 'nuggets/string/capitalize_first'
require 'nuggets/string/word_wrap'

module CMess::CLI
  module_function

  # How to split list of arguments.
  SPLIT_ARG_LIST_RE = /\s*[,\s]\s*/.freeze

  def parse_options(&block)
    OptionParser.new(nil, 40, &block).parse!
  end

  def arg_list(arg)
    arg.split(SPLIT_ARG_LIST_RE)
  end

  def ensure_readable(file)
    abort "Can't find input file: #{file}" unless File.readable?(file)
  end

  def ensure_directory(dir)
    abort "Directory not found: #{dir}" unless File.directory?(dir)
  end

  def open_file_in_place(file)
    [open_temporary_input(file), File.open(file, 'w')]
  end

  def open_file_or_std(file, mode = 'r')
    if file == '-'
      case mode
      when 'r' then STDIN
      when 'w' then STDOUT
      when 'a' then STDERR
      else raise ArgumentError, "don't know how to handle mode `#{mode}'"
      end
    else
      ensure_readable(file) unless mode == 'w'
      File.open(file, mode)
    end
  end

  def open_temporary_input(*files)
    temp = Tempfile.new('cmess_cli')

    files.each do |file|
      if file == '-'
        STDIN.each { |line| temp << line }
      else
        ensure_readable(file)
        File.foreach(file) { |line| temp << line }
      end
    end

    # return File, instead of Tempfile
    temp.close
    temp.open
  end

  def trailing_args_as_input(options)
    unless ARGV.empty? || options[:input_set]
      options[:input] =
        if ARGV.size == 1
          open_file_or_std(ARGV.first)
        else
          open_temporary_input(*ARGV)
        end
    end
  end

  def determine_system_encoding
    ENV.user_encoding || lambda {
      abort <<~EOT
        Your system's encoding couldn't be determined automatically -- please specify
        it explicitly via the ENCODING environment variable or via the '-t' option.
      EOT
    }.tap do |dummy|
      def dummy.to_s
        'NOT FOUND'
      end
    end
  end

  def cli
    yield
  rescue StandardError => err
    if $VERBOSE
      backtrace = err.backtrace
      fromtrace = backtrace[1..-1].map { |i| "\n        from #{i}" }

      abort "#{backtrace.first} #{err} (#{err.class})#{fromtrace}"
    else
      abort "#{err.to_s.capitalize_first} [#{err.backtrace.first}]"
    end
  end
end
