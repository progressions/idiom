require 'rubygems'
require 'active_support'
require 'rtranslate'
require 'timer'
require 'yrb'
require 'yaml'

module Idiom #:nodoc:
  # Finds English language translation keys which have not been translated 
  # and translates them through Google Translate.
  #
  class Base
    # Mapping of the way I18n country codes with the Google Translate codes.
    #
    # The key is the I18n representation, and the value is the code Google Translate would expect.
    #
    LOCALES = {
      "de-DE" => "de",
      "en-MY" => "en",
      "en-SG" => "en",
      "es-MX" => "es",
      "it-IT" => "it",
      "vi-VN" => "vi",
      "zh-Hant-TW" => "zh-TW",
      "en-AA" => "en",
      "en-NZ" => "en",
      "en-US" => "en",
      "fr-FR" => "fr",
      "ko-KR" => "ko",
      "zh-Hans-CN" => "zh-CN",
      "en-AU" => "en",
      "en-PH" => "en",
      "es-ES" => "es",
      "id-ID" => "id",
      "pt-BR" => "PORTUGUESE",
      "zh-Hant-HK" => "zh-CN",
    }

    # Original filename to translate.
    #
    attr_accessor :source
    
    # Destination directory to output the translated files to.
    #
    attr_accessor :destination
    
    # Write the translated strings into a directory for each language?
    #
    attr_accessor :use_dirs
    
    # Array of languages to translate into.
    #
    attr_accessor :languages
    
    class << self
      
      def translate(options={})
        @source = options[:source]
        @destination = options[:destination]
        @use_dirs = options[:use_dirs]
        Timer.new.time do
          Dir[@source].each do |path|
            $stdout.puts "Processing #{path}"
            if path =~ /\.yml$/i
              Idiom::Yaml.new(options.merge({:source => path})).generate
            end
            if path =~ /\.pres$/i
              Idiom::Yrb.new(options.merge({:source => path})).generate
            end
          end
        end
      end
      
    end
    
    def initialize(options={})
      @source = File.expand_path(options[:source])
      @overwrite = options[:overwrite]
      @languages = options[:languages]
      
      @base_source = @source.gsub(/_en-US/, "")
      
      # base directory of the source file
      #
      @source_dir = File.dirname(@source)
      
      # if they specify the :use_dirs option, use that
      # if not, detect whether the source path uses directories for each language
      #
      if options.has_key?(:use_dirs)
        @use_dirs = options[:use_dirs]
      else
        @use_dirs = @source_dir =~ /\/en-US$/
      end
      
      if @use_dirs
        @source_dir = File.dirname(@source).gsub(/\/en-US$/, "")
      end
      @destination = options[:destination] || @source_dir
    end
    
    def generate
      copy_lines_to_all_locales
    end
    
    def locales
      @languages || LOCALES.keys
    end
    
    def use_directories?
      use_dirs
    end
    
    def destination_path(lang)
      output_path = File.basename(@base_source).split(".").first
      if use_directories?
        "#{destination}/#{lang}/#{output_path}_#{lang}.#{extension}"
      else
        "#{destination}/#{output_path}_#{lang}.#{extension}"
      end
    end
    
    def non_us_locales
      @non_us_locales ||= locales.select do |lang|
        lang != "en-US"
      end
    end

    def copy_lines_to_all_locales
      non_us_locales.each do |lang|
        code = LOCALES[lang]
        destination = ensure_destination_path_exists(lang)
        new_content = each_line do |line|
          copy_and_translate_line(line, lang)
        end
        write_content(destination, new_content)
        clear_all_keys
      end
    end
    
    def ensure_destination_path_exists(lang)
      dest = destination_path(lang)
      dir = File.dirname(dest)
      FileUtils.mkdir_p(dir)
      
      dest
    end
    
    def write_content(destination, content)
      unless content.blank?
        $stdout.puts "Writing to #{destination}"
        $stdout.puts content
        $stdout.puts
        File.open(destination, "a") do |f|
          f.puts
          f.puts new_translation_message
          f.puts content
        end
      end        
    end
    
    def new_translation_message
      now = Time.now
      
      date = now.day
      month = now.month
      year = now.year
      
      timestamp = "#{month}/#{date}/#{year}"
      output = []
      output << "# "
      output << "# Keys translated automatically on #{timestamp}."
      output << "# "
      
      output.join("\n")
    end
    
    def each_line
      output = []
      @lines ||= File.readlines(source)
      
      @lines.each do |line|
        new_line = yield line
        output << new_line
      end
      output.compact.join("\n")
    end
    
    def parse(p)
      raise "Define in child"
    end
    
    def all_keys(lang)
      unless @all_keys
        @all_keys = {}
        Dir[destination_file_or_directory(lang)].each do |path|
          if File.exists?(path)
            keys = parse(path)
            @all_keys = @all_keys.merge(keys)
          end
        end
      end
      @all_keys
    end
    
    def destination_file_or_directory(lang)
      if use_directories?
        dir = File.dirname(destination_path(lang))
        "#{dir}/*.#{extension}"
      else
        destination_path(lang)
      end
    end
    
    def clear_all_keys
      @all_keys = nil
    end
  
    def copy_and_translate_line(line, lang)
      line = line.split("\n").first
      if comment?(line) || line.blank?
        nil
      else
        translate_new_key(line, lang)
      end
    end
    
    def key_is_new?(k, lang)
      k && !all_keys(lang).has_key?(k)
    end
    
    def translate_new_key(line, lang)
      k, v = key_and_value_from_line(line)
      if @overwrite || key_is_new?(k, lang)
        format(k, translate(v, lang))
      else
        nil
      end        
    end
    
    def translate(value, lang)
      code = LOCALES[lang]
      value = pre_process(value, lang)
      translation = Translate.t(value, "ENGLISH", code)
      post_process(translation, lang)
    end
    
    def pre_process(value, lang)
      vars = []
      index = 0
      while value =~ /(\{\d+\})/
        vars << $1
        value.sub!(/(\{\d+\})/, "[#{index}]")
        index += 1
      end
      
      if lang !~ /^en/ && value != value.downcase
        value = value.capitalize
      end
      
      value
    end
    
    def post_process(value, lang)
       if lang =~ /zh/
        value.gsub!("<strong>", "")
        value.gsub!("</strong>", "")
      end

      value.gsub!(/^#{194.chr}#{160.chr}/, "")

      value.gsub!(" ]", "]")
      value.gsub!("«", "\"")
      value.gsub!("»", "\"")
      value.gsub!(/\"\.$/, ".\"")
      value.gsub!(/\\ \"/, "\\\"")
      value.gsub!(/<\/ /, "<\/")
      value.gsub!(/(“|”)/, "\"")
      value.gsub!("<strong> ", "<strong>")
      value.gsub!(" </strong>", "</strong>")
      value.gsub!("&quot;", "\"")
      value.gsub!("&#39;", "\"")
      value.gsub!("&gt; ", ">")
      
      value.gsub!("\"", "'")
      value.gsub!(" \"O", " \\\"O")

      while value =~ /\[(\d)\]/
        index = $1.to_i
        value.sub!(/\[#{index}\]/, "{#{index}}")
      end
  
      value.gsub!(/\((0)\)/, "{0}")
      value.gsub!(/\((1)\)/, "{1}")
      value.gsub!(/\((2)\)/, "{2}")
      value.gsub!("（0）", "{0}")

      value.strip
    end
    
    def format(key, value)
      raise "Define in child"
    end
    
    def key_and_value_from_line(line)
      raise "Define in child"
    end
  
    def comment?(line)
      line =~ /^[\s]*#/
    end    
  end
  
  # Usage: 
  #   Translator::Yaml.new().copy
  #
  class Yaml < Base
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