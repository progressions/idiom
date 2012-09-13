# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "idiom"
  s.version = "0.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Coleman"]
  s.date = "2012-09-13"
  s.description = "Takes a set of keys in Yaml format and translates them through Google Translate."
  s.email = "progressions@gmail.com"
  s.executables = ["idiom"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "History.txt",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/idiom",
    "config/locales.yml",
    "idiom.gemspec",
    "lib/idiom.rb",
    "lib/idiom/base.rb",
    "lib/idiom/microsoft_translator.rb",
    "lib/idiom/yaml.rb",
    "lib/idiom/yrb.rb",
    "spec/idiom_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "spec/stubs.rb"
  ]
  s.homepage = "http://github.com/progressions/idiom"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.12"
  s.summary = "Translate all your application's international keys in Google Translate"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<sishen-rtranslate>, [">= 0"])
      s.add_runtime_dependency(%q<yrb>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.2.2"])
      s.add_runtime_dependency(%q<sishen-rtranslate>, [">= 1.2.9"])
      s.add_runtime_dependency(%q<timer>, [">= 0"])
      s.add_runtime_dependency(%q<natural_time>, [">= 0"])
      s.add_runtime_dependency(%q<yrb>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<sishen-rtranslate>, [">= 0"])
      s.add_dependency(%q<yrb>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<activesupport>, [">= 2.2.2"])
      s.add_dependency(%q<sishen-rtranslate>, [">= 1.2.9"])
      s.add_dependency(%q<timer>, [">= 0"])
      s.add_dependency(%q<natural_time>, [">= 0"])
      s.add_dependency(%q<yrb>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<sishen-rtranslate>, [">= 0"])
    s.add_dependency(%q<yrb>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<activesupport>, [">= 2.2.2"])
    s.add_dependency(%q<sishen-rtranslate>, [">= 1.2.9"])
    s.add_dependency(%q<timer>, [">= 0"])
    s.add_dependency(%q<natural_time>, [">= 0"])
    s.add_dependency(%q<yrb>, [">= 0"])
  end
end

