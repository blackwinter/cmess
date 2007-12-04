# Utilizes global rake-tasks: alias rake="rake -r rake -R /path/to/rakelibdir"
# (Base tasks at <http://prometheus.khi.uni-koeln.de/svn/scratch/rake-tasks/>)

require 'lib/cmess/version'

FILES = FileList['lib/**/*.rb'].to_a
EXECS = FileList['bin/*'].to_a
RDOCS = %w[README COPYING ChangeLog]
OTHER = FileList['[A-Z]*', 'example/**/*', 'data/**/*'].to_a

task(:doc_spec) {{
  :title      => 'cmess Application documentation',
  :rdoc_files => RDOCS + FILES + EXECS
}}

task(:gem_spec) {{
  :name             => 'cmess',
  :version          => CMess::VERSION,
  :summary          => "Assist with handling messed up encodings " <<
                       "(Currently includes the following tools: " <<
                       "#{EXECS.map { |e| File.basename(e) }.join(', ')})",
  :files            => FILES + EXECS + OTHER,
  :require_path     => 'lib',
  :bindir           => 'bin',
  :executables      => EXECS,
  :extra_rdoc_files => RDOCS,
  :dependencies     => %w[]
}}
