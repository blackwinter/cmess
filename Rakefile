begin
  require 'hen'
rescue LoadError
  abort "Please install the 'hen' gem first."
end

require 'lib/cmess'

Hen.lay! {{
  :rubyforge => {
    :package => 'cmess'
  },

  :gem => {
    :version      => CMess::VERSION,
    :summary      => %Q{
      Assist with handling messed up encodings (Currently includes the
      following tools: #{Dir['bin/*'].map { |e| File.basename(e) }.join(', ')})
    },
    :files        => FileList['lib/**/*.rb', 'bin/*'].to_a,
    :extra_files  => FileList['[A-Z]*', 'example/**/*', 'data/**/*'].to_a,
    :dependencies => %w[ruby-nuggets htmlentities]
  }
}}
