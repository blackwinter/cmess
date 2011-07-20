require 'bundler/gem_tasks'

namespace :guess_encoding do
  desc "Compare actual encoding and automatic guess of example files"
  task :check_examples do
    require File.join(File.dirname(__FILE__), 'lib', 'cmess', 'guess_encoding')

    E = CMess::GuessEncoding::Encoding

    Dir[File.join(File.dirname(__FILE__), 'example', 'guess_encoding', '??.*.txt')].sort.each { |example|
      language, encoding = File.basename(example, '.txt').split('.')
      encoding.upcase!

      guessed = CMess::GuessEncoding::Automatic.guess(File.open(example))

      match = case guessed
              when E::UNKNOWN
                '?'
              when E::ASCII
                '#'
              when encoding
                '+'
              else
                '-'
              end

      puts '%s %s/%-11s => %s' % [match, language, encoding, guessed]
    }
  end
end
