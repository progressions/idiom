require 'idiom/base'

module Idiom #:nodoc:
  # Usage: 
  #   Translator::Yaml.new().copy
  #
  class Yaml < Base
    def destination_path(lang)
      source
    end
    
    def extension
      "yml"
    end
    
    def parse(path)
      YAML.load_file(path)
    end
    
    def format(key, value)
      "#{key}: #{value}"
    end
    
    def key_and_value_from_line(line)
      if line =~ /^([^\:]+):(.*)/
        return $1, $2.strip
      else
        return nil, nil
      end
    end
  end
end