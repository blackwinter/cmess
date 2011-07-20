# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cmess/version"

Gem::Specification.new do |s|
  s.name = %q{cmess}
  s.version = CMess::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2011-04-29}
  s.description = %q{
        Assist with handling messed up encodings (Currently includes the
        following tools: bconv, cinderella, decode_entities, guess_encoding)
      }
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = ["bconv", "decode_entities", "guess_encoding", "cinderella"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.homepage = %q{http://prometheus.rubyforge.org/cmess}
  s.rdoc_options = ["--charset", "UTF-8", "--main", "README", "--title", "cmess Application documentation (v0.2.5)", "--line-numbers", "--all"]
  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.7.2}
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
