require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "idiom"
    gem.summary = %Q{Translate all your application's international keys in Google Translate}
    gem.description = %Q{Takes a set of keys in Yaml format and translates them through Google Translate.}
    gem.email = "progressions@gmail.com"
    gem.homepage = "http://github.com/progressions/idiom"
    gem.authors = ["Jeff Coleman"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_runtime_dependency "activesupport", ">= 2.2.2"
    gem.add_runtime_dependency "sishen-rtranslate", ">= 1.2.9"
    gem.add_runtime_dependency "timer"
    gem.add_runtime_dependency "natural_time"
    gem.add_runtime_dependency "yrb", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


task :bundle do
  require 'vendor/gems/environment'
  Bundler.require_env
end

