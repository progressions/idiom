module Idiom #:nodoc:
  # Finds English language translation keys which have not been translated 
  # and translates them through Google Translate.
  #
  module Directories #:nodoc:
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
    
    def ensure_destination_path_exists(lang)
      dest = destination_path(lang)
      dir = File.dirname(dest)
      FileUtils.mkdir_p(dir)
      
      dest
    end
    
    def destination_file_or_directory(lang)
      if use_directories?
        dir = File.dirname(destination_path(lang))
        "#{dir}/*.#{extension}"
      else
        destination_path(lang)
      end
    end    
  end
  
  module Locales #:nodoc:
    # Mapping of the I18n country codes with the Google Translate codes.
    #
    # The key is the I18n representation, and the value is the code Google Translate would expect.
    #
    
    # LOCALES = YAML.load_file("./config/locales.yml")
    CONFIG = YAML.load_file("./config/idiom.yml")
    LOCALES = CONFIG["locales"]
        
    # locales
    
    def non_us_locales
      # @non_us_locales ||= locales.select do |lang|
      #   lang != "en-US"
      # end
      locales
    end

    def locales
      @languages || LOCALES.keys
    end
  end
  
  module Processing #:nodoc:
    def pre_process(value, lang)
      # extract %{substitution_var} => @substitution_vars = ['substitution_var']
      #
      # This prevents the translator from seeing the substitution_var, in case it
      # tries to e.g. downcase it or whatever.
      @substitution_vars = []
      while value =~ /%\{([^\}]*)\}/
        value.sub! /%\{([^\}]*)\}/, "|#{@substitution_vars.count}|"
        @substitution_vars << $1
      end

      # extract '''pass through''' / ===pass through===  => @pass_through_vars = ['pass through']
      #
      # This allows string to be passed through without being translated
      # differs from @substitution_vars in that the underscore markup
      # will be stripped from the final result
      @pass_through_vars = []
      while value =~ /(?:(?:===)|(?:'''))(.*?)(?:(?:===)|(?:'''))/
        value.sub! /(?:(?:===)|(?:'''))(.*?)(?:(?:===)|(?:'''))/, "__#{@pass_through_vars.count}__"
        @pass_through_vars  << $1
      end

      vars = []
      index = 0
      while value =~ /(\{\d+\})/
        vars << $1
        value.sub!(/(\{\d+\})/, "[#{index}]")
        index += 1
      end
      
      value.gsub!("{{", "{{_")
      value.gsub!("}}", "_}}")

      value
    end

    def post_process(value, lang)
      value.gsub!(/^\"/, "")
      value.gsub!(/\"$/, "")
      # value.gsub!('"。', '。"')
      # value.gsub!(/^[''"「«]+/, "")
      # value.gsub!(/[''"」»]+$/, "")
      value.gsub!('"', "'")
      # value.gsub!("«", "")
      # value.gsub!("»", "")
      value.gsub!("&lt;", "<")
      value.gsub!("&gt;", ">")
      value.gsub!("{ ", "{")
      value.gsub!(" }", "}")
      value.gsub!("{{_", "{{")
      value.gsub!("_}}", "}}")
      value.gsub!(/\\$/, "")

      value.strip!
      value = "\"#{value}\"" if value.present?

      # Replace substitution vars
      while value =~ /\|([^\|]+)\|/ 
        value.sub! /\|([^\|]+)\|/, "%{#{@substitution_vars[$1.to_i]}}" 
      end

      # Replace pass-through content
      while value =~ /__(.*?)__/
        value.sub! /__(.*?)__/, @pass_through_vars[$1.to_i]
      end

      value
    end    
  end

  module ClassMethods #:nodoc:
    def translate(options={})
      options.stringify_keys!
      
      @source = options["source"]
      @destination = options["destination"]
      @use_dirs = options["use_dirs"]
      
      Timer.new.time do
        find_and_translate_all(options)
      end
    end
    
    def source_files
      if @source =~ /\.(yml|pres)$/
        source_files = Dir[@source]
      else
        dir = File.expand_path(@source)
        source_files = Dir["#{dir}/**/*_en-US.pres"] + Dir["#{dir}/**/*_en-US.yml"]
        source_files.flatten
      end        
    end
    
    def find_and_translate_all(options={})
      options.stringify_keys!
      
      source_files.each do |path|
        $stdout.puts "Processing #{path}"
        translate_file(path, options)
      end        
    end
    
    def translate_file(path, options={})
      options.stringify_keys!
      if path =~ /\.yml$/i
        Idiom::Yaml.new(options.merge({"source" => path})).generate
      end
      if path =~ /\.pres$/i
        Idiom::Yrb.new(options.merge({"source" => path})).generate
      end        
    end
  end
  
  class Base
    extend Idiom::ClassMethods
    include Idiom::Directories
    include Idiom::Locales
    include Idiom::Processing

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
        
    # Cached array of subsitution variables
    #
    attr_accessor :substitution_vars

    # Cached array of pass-through content
    #
    attr_accessor :pass_through_vars
    
    def initialize(options={})
      options.stringify_keys!
      
      @source = File.expand_path(options["source"])
      @overwrite = options["overwrite"]
      @languages = options["languages"]
      @substitution_vars = []
      @pass_through_vars = []
      
      @base_source = @source.gsub(/_en-US/, "")
      
      # base directory of the source file
      #
      @source_dir = File.dirname(@source)
      
      # if they specify the :use_dirs option, use that
      # if not, detect whether the source path uses directories for each language
      #
      if options.has_key?("use_dirs")
        @use_dirs = options["use_dirs"]
      else
        @use_dirs = @source_dir =~ /\/en-US$/
      end
      
      if @use_dirs
        @source_dir = File.dirname(@source).gsub(/\/en-US$/, "")
      end
      @destination = options["destination"] || @source_dir
    end
    
    def generate
      before_translation
      # RM NOTE: Async concurrent by language?
      non_us_locales.each do |lang|
        code = LOCALES[lang]
        destination = ensure_destination_path_exists(lang)
        # RM NOTE: this breaks on multi-line strings
        new_content = each_line do |line|
          copy_and_translate_line(line, lang)
        end
        write_content(destination, new_content)
        clear_all_keys
      end
      after_translation
    end
    
    def before_translation
    end
    
    def after_translation
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
    
    def clear_all_keys
      @all_keys = nil
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
  
    def copy_and_translate_line(line, lang)
      line = line.split("\n").first
      if comment?(line) || line.blank?
        nil
      elsif line.strip == "en:"
        "#{lang}:"
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
        translation = translate(v, lang)
      
        if translation == "Error: invalid result data"
          return nil
        end
        
        format(k, translation)
      else
        nil
      end        
    end
    
    def translate(value, lang)
      value = value.gsub(/^'/, "").gsub(/'$/, "")
      return '' if value == ''
      $stdout.puts("Translating #{value} into #{lang}...")
      code = LOCALES[lang]
      value = pre_process(value, lang)

      translation = do_translate(value, code)

      value = post_process(translation, lang)
      value
    end
    
    def do_translate(value, code)
      if CONFIG["library"].to_s.downcase == "google"
        Translate.t(value, "ENGLISH", code)
        sleep(5)
      else
        MicrosoftTranslator.t(value, code)
      end
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
end
