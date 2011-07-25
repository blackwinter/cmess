# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cmess}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Jens Wille}]
  s.date = %q{2011-07-25}
  s.description = %q{
        Assist with handling messed up encodings (Currently includes the
        following tools: bconv, cinderella, decode_entities, guess_encoding)
      }
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = [%q{bconv}, %q{decode_entities}, %q{guess_encoding}, %q{cinderella}]
  s.extra_rdoc_files = [%q{README}, %q{COPYING}, %q{ChangeLog}]
  s.files = [%q{lib/cmess.rb}, %q{lib/cmess/guess_encoding/automatic.rb}, %q{lib/cmess/guess_encoding/encoding.rb}, %q{lib/cmess/guess_encoding/manual.rb}, %q{lib/cmess/bconv.rb}, %q{lib/cmess/cli.rb}, %q{lib/cmess/cinderella.rb}, %q{lib/cmess/guess_encoding.rb}, %q{lib/cmess/decode_entities.rb}, %q{lib/cmess/version.rb}, %q{bin/bconv}, %q{bin/decode_entities}, %q{bin/guess_encoding}, %q{bin/cinderella}, %q{data/csets/latin1.yaml}, %q{data/csets/iso_8859-15.yaml}, %q{data/csets/iso_8859-1.yaml}, %q{data/csets/unicode/latin_extended_a.yaml}, %q{data/csets/unicode/basic_latin.yaml}, %q{data/csets/unicode/ipa_extensions.yaml}, %q{data/csets/unicode/latin_extended_b.yaml}, %q{data/csets/unicode/latin-extended-d.yaml}, %q{data/csets/unicode/letterlike_symbols.yaml}, %q{data/csets/unicode/latin_extended_additional.yaml}, %q{data/csets/unicode/greek.yaml}, %q{data/csets/unicode/latin-extended-c.yaml}, %q{data/csets/unicode/spacing_modifier_letters.yaml}, %q{data/csets/unicode/cyrillic-supplement.yaml}, %q{data/csets/unicode/cyrillic.yaml}, %q{data/csets/unicode/latin_1_supplement.yaml}, %q{data/csets/utf-8.yaml}, %q{data/csets/utf8.yaml}, %q{data/test_chars.yaml}, %q{data/chartab.yaml}, %q{README}, %q{ChangeLog}, %q{Rakefile}, %q{COPYING}, %q{example/guess_encoding/en.utf-8.txt}, %q{example/guess_encoding/de.utf-8.txt}, %q{example/guess_encoding/it.utf-8.txt}, %q{example/guess_encoding/check_results}, %q{example/guess_encoding/fr.utf-8.txt}, %q{example/cinderella/empty6-slash_repaired.txt}, %q{example/cinderella/empty6-slash.txt}, %q{example/cinderella/crop}, %q{example/cinderella/pot}, %q{example/cinderella/crop_repaired}]
  s.homepage = %q{http://prometheus.rubyforge.org/cmess}
  s.rdoc_options = [%q{--charset}, %q{UTF-8}, %q{--title}, %q{cmess Application documentation (v0.3.0)}, %q{--main}, %q{README}, %q{--line-numbers}, %q{--all}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Assist with handling messed up encodings (Currently includes the following tools: bconv, cinderella, decode_entities, guess_encoding)}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
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
