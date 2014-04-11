$:.unshift(File.expand_path('../lib', __FILE__))

require 'cmess'

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
      dependencies: %w[htmlentities safe_yaml] << ['ruby-nuggets', '>= 0.3.3'],

      required_ruby_version: '>= 1.9.2'
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end

namespace :guess_encoding do

  desc "Compare actual encoding and automatic guess of example files"
  task :check_examples do
    E = CMess::GuessEncoding::Encoding

    Dir[File.join(File.dirname(__FILE__), 'example', 'guess_encoding', '??.*.txt')].sort.each { |example|
      language, encoding = File.basename(example, '.txt').split('.')
      encoding.upcase!

      result = CMess::GuessEncoding::Automatic.guess(File.open(example))

      puts '%s %s/%-11s => %s' % [case result
        when E::UNKNOWN then '?'
        when E::ASCII   then '#'
        when encoding   then '+'
        else                 '-'
      end, language, encoding, result]
    }
  end

end
