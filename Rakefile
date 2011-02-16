require File.expand_path(%q{../lib/cmess/version}, __FILE__)

begin
  require 'hen'

  Hen.lay! {{
    :rubyforge => {
      :project => %q{prometheus},
      :package => %q{cmess}
    },

    :gem => {
      :version      => CMess::VERSION,
      :summary      => %Q{
        Assist with handling messed up encodings (Currently includes the
        following tools: #{Dir['bin/*'].map { |e| File.basename(e) }.sort.join(', ')})
      },
      :author       => %q{Jens Wille},
      :email        => %q{jens.wille@uni-koeln.de},
      :extra_files  => FileList['data/**/*'].to_a,
      :dependencies => [['ruby-nuggets', '>= 0.3.3'], 'htmlentities']
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end

namespace :guess_encoding do

  desc "Compare actual encoding and automatic guess of example files"
  task :check_examples do
    require 'lib/cmess/guess_encoding'

    E = CMess::GuessEncoding::Encoding

    Dir[File.join(File.dirname(__FILE__), 'example', 'guess_encoding', '??.*.txt')].sort.each { |example|
      language, encoding = File.basename(example, '.txt').split('.')
      encoding.upcase!

      guessed = CMess::GuessEncoding::Automatic.guess(File.open(example))

      match = case guessed
        when E::UNKNOWN: '?'
        when E::ASCII:   '#'
        when encoding:   '+'
        else             '-'
      end

      puts '%s %s/%-11s => %s' % [match, language, encoding, guessed]
    }
  end

end
