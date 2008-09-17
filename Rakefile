$:.unshift('lib')
require 'cmess'

begin
  require 'hen'

  Hen.lay! {{
    :rubyforge => {
      :package => 'cmess'
    },

    :gem => {
      :version      => CMess::VERSION,
      :summary      => %Q{
        Assist with handling messed up encodings (Currently includes the
        following tools: #{Dir['bin/*'].map { |e| File.basename(e) }.sort.join(', ')})
      },
      :files        => FileList['lib/**/*.rb', 'bin/*'].to_a,
      :extra_files  => FileList['[A-Z]*', 'example/**/*', 'data/**/*'].to_a,
      :dependencies => [['ruby-nuggets', '>= 0.3.3'], 'htmlentities']
    }
  }}
rescue LoadError
  abort "Please install the 'hen' gem first."
end

namespace :guess_encoding do

  require 'cmess/guess_encoding'
  include CMess::GuessEncoding::Encoding

  desc "Compare actual encoding and automatic guess of example files"
  task :check_examples do
    Dir[File.join(File.dirname(__FILE__), 'example', 'guess_encoding', '??.*.txt')].sort.each { |example|
      language, encoding = File.basename(example, '.txt').split('.')
      encoding.upcase!

      guessed = CMess::GuessEncoding::Automatic.guess(File.open(example))

      match = case guessed
        when UNKNOWN:  '?'
        when ASCII:    '#'
        when encoding: '+'
        else           '-'
      end

      puts '%s %s/%-11s => %s' % [match, language, encoding, guessed]
    }
  end

end
