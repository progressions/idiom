require 'idiom/base'
    
module Idiom #:nodoc:
  # Usage: 
  #   Translator::Yaml.new().copy
  #
  class Yaml < Base
    def destination_path(lang=nil)
      "#{source}.tmp"
    end
    
    def after_translation
      system "cat #{destination_path} >> #{source} && rm #{destination_path}"
      end
    
    def extension
      "yml"
    end

    def generate
      yaml = YAML.load_file(source).stringify_keys!
      english = yaml["en"] || yaml["en-US"]

      non_us_locales.each do |lang|
        destination = ensure_destination_path_exists(lang)

        code = LOCALES[lang]

        tree = { lang => Marshal.load( Marshal.dump(english) ) }
        tree.each_pair {|key, leaf| {key => parse_node(leaf, lang)} }

        write_content( destination, tree.ya2yaml(:syck_compatible => true) )
      end

      after_translation
    end

    private

    def parse_node(node, lang)
      case node.class.name
      when "Hash"
        node.update(node) {|key,leaf| parse_node(leaf, lang)}
      when "Array"
        node.map {|term| translate(term, lang).to_s }
      else
        translate(node, lang).to_s
      end
    end
  end
end
