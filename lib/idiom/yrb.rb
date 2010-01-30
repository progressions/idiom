require 'idiom/base'

module Idiom #:nodoc
  # Usage: 
  #   Translator::Yrb.new(:source => "./translations/en-US.pres", :destination => "./translations",
  #   :use_dirs => false).translate
  #
  class Yrb < Base
    def extension
      "pres"
    end
    
    def parse(p)
      YRB.load_file(p)
    end
    
    def format(key, value)
      "#{key}=#{value}"
    end
    
    def key_and_value_from_line(line)
      if line =~ /^([^\=]+)=(.+)/
        return $1, $2
      else
        return nil, nil
      end
    end
  end
end