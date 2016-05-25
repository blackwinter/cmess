require_relative 'lib/cmess/version'

begin
  require 'hen'

  Hen.lay! {{
    gem: {
      name:         %q{cmess},
      version:      CMess::VERSION,
      summary:      <<-EOT,
Assist with handling messed up encodings (Currently includes the
following tools: #{Dir['bin/*'].map { |e| File.basename(e) }.sort.join(', ')})
      EOT
      author:       %q{Jens Wille},
      email:        %q{jens.wille@gmail.com},
      license:      %q{AGPL-3.0},
      homepage:     :blackwinter,
      extra_files:  FileList['data/**/*'].to_a,
      dependencies: {
        htmlentities: '~> 4.3',
        nuggets:      '~> 1.5',
        safe_yaml:    '~> 1.0'
      },

      required_ruby_version: '>= 1.9.3'
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end

namespace :guess_encoding do

  desc 'Compare actual encoding and automatic guess of example files'
  task :check_examples do
    require_relative 'lib/cmess'
    require_relative 'lib/cmess/guess_encoding'

    e = CMess::GuessEncoding::Encoding

    Dir[File.expand_path('../example/guess_encoding/??.*.txt', __FILE__)].sort.each { |example|
      language, encoding = File.basename(example, '.txt').split('.')
      encoding.upcase!

      result = CMess::GuessEncoding::Automatic.guess(File.open(example))

      puts '%s %s/%-11s => %s' % [case result
        when e::UNKNOWN then '?'
        when e::ASCII   then '#'
        when encoding   then '+'
        else                 '-'
      end, language, encoding, result]
    }
  end

end
