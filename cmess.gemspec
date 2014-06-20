# -*- encoding: utf-8 -*-
# stub: cmess 0.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "cmess"
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jens Wille"]
  s.date = "2014-06-20"
  s.description = "Assist with handling messed up encodings (Currently includes the\nfollowing tools: bconv, cinderella, decode_entities, guess_encoding)\n"
  s.email = "jens.wille@gmail.com"
  s.executables = ["bconv", "cinderella", "decode_entities", "guess_encoding"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["COPYING", "ChangeLog", "README", "Rakefile", "bin/bconv", "bin/cinderella", "bin/decode_entities", "bin/guess_encoding", "data/chartab.yaml", "data/csets/iso_8859-1.yaml", "data/csets/iso_8859-15.yaml", "data/csets/latin1.yaml", "data/csets/unicode/basic_latin.yaml", "data/csets/unicode/cyrillic-supplement.yaml", "data/csets/unicode/cyrillic.yaml", "data/csets/unicode/greek.yaml", "data/csets/unicode/ipa_extensions.yaml", "data/csets/unicode/latin-extended-c.yaml", "data/csets/unicode/latin-extended-d.yaml", "data/csets/unicode/latin_1_supplement.yaml", "data/csets/unicode/latin_extended_a.yaml", "data/csets/unicode/latin_extended_additional.yaml", "data/csets/unicode/latin_extended_b.yaml", "data/csets/unicode/letterlike_symbols.yaml", "data/csets/unicode/spacing_modifier_letters.yaml", "data/csets/utf-8.yaml", "data/csets/utf8.yaml", "data/test_chars.yaml", "example/cinderella/crop", "example/cinderella/crop_repaired", "example/cinderella/empty6-slash.txt", "example/cinderella/empty6-slash_repaired.txt", "example/cinderella/pot", "example/guess_encoding/check_results", "example/guess_encoding/de.utf-8.txt", "example/guess_encoding/en.utf-8.txt", "example/guess_encoding/fr.utf-8.txt", "example/guess_encoding/it.utf-8.txt", "lib/cmess.rb", "lib/cmess/bconv.rb", "lib/cmess/cinderella.rb", "lib/cmess/cli.rb", "lib/cmess/decode_entities.rb", "lib/cmess/guess_encoding.rb", "lib/cmess/guess_encoding/automatic.rb", "lib/cmess/guess_encoding/encoding.rb", "lib/cmess/guess_encoding/manual.rb", "lib/cmess/version.rb"]
  s.homepage = "http://github.com/blackwinter/cmess"
  s.licenses = ["AGPL-3.0"]
  s.post_install_message = "\ncmess-0.4.1 [2014-06-20]:\n\n* Various updates/refactorings.\n* Housekeeping.\n\n"
  s.rdoc_options = ["--title", "cmess Application documentation (v0.4.1)", "--charset", "UTF-8", "--line-numbers", "--all", "--main", "README"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubygems_version = "2.3.0"
  s.summary = "Assist with handling messed up encodings (Currently includes the following tools: bconv, cinderella, decode_entities, guess_encoding)"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<htmlentities>, [">= 0"])
      s.add_runtime_dependency(%q<nuggets>, [">= 0"])
      s.add_runtime_dependency(%q<safe_yaml>, [">= 0"])
      s.add_development_dependency(%q<hen>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<htmlentities>, [">= 0"])
      s.add_dependency(%q<nuggets>, [">= 0"])
      s.add_dependency(%q<safe_yaml>, [">= 0"])
      s.add_dependency(%q<hen>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<htmlentities>, [">= 0"])
    s.add_dependency(%q<nuggets>, [">= 0"])
    s.add_dependency(%q<safe_yaml>, [">= 0"])
    s.add_dependency(%q<hen>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
