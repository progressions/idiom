class MicrosoftTranslator
  CONFIG = YAML.load_file("./config/idiom.yml")
    
  class << self
    def t(value, code)
      value = URI.encode(value)
      # "http://api.microsofttranslator.com/V2/Http.svc/Translate?to=#{code}&text=#{}&appId=2CEF8B6B9CA38C6C8355B154C760C28A66E4339F"
      
      appId = CONFIG["appId"]
      url = "http://api.microsofttranslator.com/V2/Http.svc/Translate?to=#{code}&text=#{value}&appId=#{appId}"
      result = Net::HTTP.get(URI.parse(url))
      
      if result =~ /<string xmlns=\"http:\/\/schemas.microsoft.com\/2003\/10\/Serialization\/\">(.*)<\/string>/
        output = $1
      end
      if result =~ /Message: (.*)/
        $stdout.puts(result)
      end
      if result =~ /AppId is over the quota/
        raise "AppId is over the quota"
      end
      output.to_s
    end
  end
end
