# -*- encoding: utf-8 -*-
# stub: cmess 0.5.1 ruby lib

Gem::Specification.new do |s|
  s.name = "cmess".freeze
  s.version = "0.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jens Wille".freeze]
  s.date = "2016-05-25"
  s.description = "Assist with handling messed up encodings (Currently includes the\nfollowing tools: bconv, cinderella, decode_entities, guess_encoding)\n".freeze
  s.email = "jens.wille@gmail.com".freeze
  s.executables = ["bconv".freeze, "cinderella".freeze, "decode_entities".freeze, "guess_encoding".freeze]
  s.extra_rdoc_files = ["README".freeze, "COPYING".freeze, "ChangeLog".freeze]
  s.files = ["COPYING".freeze, "ChangeLog".freeze, "README".freeze, "Rakefile".freeze, "bin/bconv".freeze, "bin/cinderella".freeze, "bin/decode_entities".freeze, "bin/guess_encoding".freeze, "data/chartab.yaml".freeze, "data/csets/iso_8859-1.yaml".freeze, "data/csets/iso_8859-15.yaml".freeze, "data/csets/latin1.yaml".freeze, "data/csets/unicode/basic_latin.yaml".freeze, "data/csets/unicode/cyrillic-supplement.yaml".freeze, "data/csets/unicode/cyrillic.yaml".freeze, "data/csets/unicode/greek.yaml".freeze, "data/csets/unicode/ipa_extensions.yaml".freeze, "data/csets/unicode/latin-extended-c.yaml".freeze, "data/csets/unicode/latin-extended-d.yaml".freeze, "data/csets/unicode/latin_1_supplement.yaml".freeze, "data/csets/unicode/latin_extended_a.yaml".freeze, "data/csets/unicode/latin_extended_additional.yaml".freeze, "data/csets/unicode/latin_extended_b.yaml".freeze, "data/csets/unicode/letterlike_symbols.yaml".freeze, "data/csets/unicode/spacing_modifier_letters.yaml".freeze, "data/csets/utf-8.yaml".freeze, "data/csets/utf8.yaml".freeze, "data/test_chars.yaml".freeze, "example/cinderella/crop".freeze, "example/cinderella/crop_repaired".freeze, "example/cinderella/empty6-slash.txt".freeze, "example/cinderella/empty6-slash_repaired.txt".freeze, "example/cinderella/pot".freeze, "example/guess_encoding/check_results".freeze, "example/guess_encoding/de.utf-8.txt".freeze, "example/guess_encoding/en.utf-8.txt".freeze, "example/guess_encoding/fr.utf-8.txt".freeze, "example/guess_encoding/it.utf-8.txt".freeze, "lib/cmess.rb".freeze, "lib/cmess/bconv.rb".freeze, "lib/cmess/cinderella.rb".freeze, "lib/cmess/cli.rb".freeze, "lib/cmess/decode_entities.rb".freeze, "lib/cmess/guess_encoding.rb".freeze, "lib/cmess/guess_encoding/automatic.rb".freeze, "lib/cmess/guess_encoding/encoding.rb".freeze, "lib/cmess/guess_encoding/manual.rb".freeze, "lib/cmess/version.rb".freeze]
  s.homepage = "http://github.com/blackwinter/cmess".freeze
  s.licenses = ["AGPL-3.0".freeze]
  s.post_install_message = "\ncmess-0.5.1 [2016-05-26]:\n\n* +cinderella+: Fixed YAML loading and option handling.\n* Fixed error message for missing required options.\n* Fixed YAML files for +cinderella+.\n\n".freeze
  s.rdoc_options = ["--title".freeze, "cmess Application documentation (v0.5.1)".freeze, "--charset".freeze, "UTF-8".freeze, "--line-numbers".freeze, "--all".freeze, "--main".freeze, "README".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "2.6.4".freeze
  s.summary = "Assist with handling messed up encodings (Currently includes the following tools: bconv, cinderella, decode_entities, guess_encoding)".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<htmlentities>.freeze, ["~> 4.3"])
      s.add_runtime_dependency(%q<nuggets>.freeze, ["~> 1.5"])
      s.add_runtime_dependency(%q<safe_yaml>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<hen>.freeze, [">= 0.8.5", "~> 0.8"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<htmlentities>.freeze, ["~> 4.3"])
      s.add_dependency(%q<nuggets>.freeze, ["~> 1.5"])
      s.add_dependency(%q<safe_yaml>.freeze, ["~> 1.0"])
      s.add_dependency(%q<hen>.freeze, [">= 0.8.5", "~> 0.8"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<htmlentities>.freeze, ["~> 4.3"])
    s.add_dependency(%q<nuggets>.freeze, ["~> 1.5"])
    s.add_dependency(%q<safe_yaml>.freeze, ["~> 1.0"])
    s.add_dependency(%q<hen>.freeze, [">= 0.8.5", "~> 0.8"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
