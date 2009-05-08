# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cmess}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2009-05-08}
  s.description = %q{
        Assist with handling messed up encodings (Currently includes the
        following tools: bconv, cinderella, decode_entities, guess_encoding)
      }
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = ["guess_encoding", "cinderella", "bconv", "decode_entities"]
  s.extra_rdoc_files = ["COPYING", "ChangeLog", "README"]
  s.files = ["lib/cmess/guess_encoding/manual.rb", "lib/cmess/guess_encoding/automatic.rb", "lib/cmess/guess_encoding/encoding.rb", "lib/cmess/decode_entities.rb", "lib/cmess/cli.rb", "lib/cmess/cinderella.rb", "lib/cmess/bconv.rb", "lib/cmess/guess_encoding.rb", "lib/cmess/version.rb", "lib/cmess.rb", "bin/guess_encoding", "bin/cinderella", "bin/bconv", "bin/decode_entities", "Rakefile", "COPYING", "ChangeLog", "README", "example/guess_encoding", "example/guess_encoding/en.utf-8.txt", "example/guess_encoding/fr.utf-8.txt", "example/guess_encoding/check_results", "example/guess_encoding/it.utf-8.txt", "example/guess_encoding/de.utf-8.txt", "example/cinderella", "example/cinderella/pot", "example/cinderella/empty6-slash_repaired.txt", "example/cinderella/crop", "example/cinderella/empty6-slash.txt", "example/cinderella/crop_repaired", "data/chartab.yaml", "data/csets", "data/csets/unicode", "data/csets/unicode/latin-extended-c.yaml", "data/csets/unicode/spacing_modifier_letters.yaml", "data/csets/unicode/latin_extended_a.yaml", "data/csets/unicode/ipa_extensions.yaml", "data/csets/unicode/latin_1_supplement.yaml", "data/csets/unicode/greek.yaml", "data/csets/unicode/latin_extended_b.yaml", "data/csets/unicode/latin-extended-d.yaml", "data/csets/unicode/basic_latin.yaml", "data/csets/unicode/latin_extended_additional.yaml", "data/csets/unicode/cyrillic.yaml", "data/csets/unicode/cyrillic-supplement.yaml", "data/csets/unicode/letterlike_symbols.yaml", "data/csets/iso_8859-1.yaml", "data/csets/utf8.yaml", "data/csets/utf-8.yaml", "data/csets/latin1.yaml", "data/csets/iso_8859-15.yaml", "data/test_chars.yaml"]
  s.homepage = %q{http://prometheus.rubyforge.org/cmess}
  s.rdoc_options = ["--all", "--main", "README", "--line-numbers", "--inline-source", "--title", "cmess Application documentation", "--charset", "UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Assist with handling messed up encodings (Currently includes the following tools: bconv, cinderella, decode_entities, guess_encoding)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ruby-nuggets>, [">= 0.3.3"])
      s.add_runtime_dependency(%q<htmlentities>, [">= 0"])
    else
      s.add_dependency(%q<ruby-nuggets>, [">= 0.3.3"])
      s.add_dependency(%q<htmlentities>, [">= 0"])
    end
  else
    s.add_dependency(%q<ruby-nuggets>, [">= 0.3.3"])
    s.add_dependency(%q<htmlentities>, [">= 0"])
  end
end