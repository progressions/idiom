require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Idiom" do
  before(:each) do
    stub_timer
    stub_yrb
    stub_yaml
    stub_screen_io
    stub_file_io
  end
  
  describe "base" do
    before(:each) do
      @translator = mock('translator', :generate => true)
      Idiom::Yrb.stub!(:new).and_return(@translator)
      Idiom::Yaml.stub!(:new).and_return(@translator)
    end
    
    it "should create an Idiom for each Yaml file" do
      Idiom::Yaml.should_receive(:new).and_return(@translator)
      Idiom::Base.translate(:source => "path.yml")
    end
    
    it "should create an Idiom for each YRB file" do
      Idiom::Yrb.should_receive(:new).and_return(@translator)
      Idiom::Base.translate(:source => "path.pres")
    end
  end
  
  describe "yrb" do
    before(:each) do
      @yrb_file = <<-YRB
FIRST=first key
SECOND=second key
      YRB
      File.stub!(:readlines).and_return(@yrb_file)
      Translate.stub!(:t).with("first key", "ENGLISH", anything).and_return("translated first key")
      Translate.stub!(:t).with("second key", "ENGLISH", anything).and_return("translated second key")
      @source = "./translations/path.pres"
    end
    
    it "should create the destination path if it does not exist" do
      Idiom::Yrb::LOCALES.each do |lang, code|
        FileUtils.should_receive(:mkdir_p).with("./translations") unless lang == "en-US"
      end
      Idiom::Yrb.new(:source => @source).generate
    end
    
    it "should write to the destination path" do
      Idiom::Yrb::LOCALES.each do |lang, code|
        File.should_receive(:open).with("./translations/path_#{lang}.pres", "a") unless lang == "en-US"
      end
      Idiom::Yrb.new(:source => @source).generate
    end
    
    describe "directories" do
      before(:each) do
        @source = "./translations/en-US/path.pres"
      end
    
      it "should write to directories" do
        Idiom::Yrb::LOCALES.each do |lang, code|
          File.should_receive(:open).with("./translations/#{lang}/path_#{lang}.pres", "a") unless lang == "en-US"
        end
        Idiom::Yrb.new(:source => @source, :use_dirs => true).generate
      end
    
      it "should create the destination path with directories if it does not exist" do
        Idiom::Yrb::LOCALES.each do |lang, code|
          FileUtils.should_receive(:mkdir_p).with("./translations/#{lang}") unless lang == "en-US"
        end
        Idiom::Yrb.new(:source => @source, :use_dirs => true).generate
      end
    end
    
    it "should translate the first string" do
      @file.should_receive(:puts).with(/FIRST=translated first key/)
      Idiom::Yrb.new(:source => @source).generate
    end
    
    it "should translate the second string" do
      @file.should_receive(:puts).with(/SECOND=translated second key/)
      Idiom::Yrb.new(:source => @source).generate
    end
    
    # describe "key exists" do
    #   before(:each) do
    #     YRB.stub!(:load_file).and_return({"FIRST" => "old translated first key"})
    #   end
    #   
    #   it "should not translate a key that is already translated" do
    #     @file.should_not_receive(:puts).with(/FIRST=translated first key/)
    #     Idiom::Yrb.new(:source => @source).generate
    #   end
    #   
    #   it "should translate a key that is already translated if overwrite is true" do
    #     @file.should_receive(:puts).with(/FIRST=translated first key/)
    #     Idiom::Yrb.new(:source => @source, :overwrite => true).generate
    #   end
    # end
    
    describe "languages" do
      it "should only translate the specified set of languages" do
        @languages = ["de-DE", "zh-Hant-HK"]
        Idiom::Yrb::LOCALES.each do |lang, code|
          if @languages.include?(lang)
            File.should_receive(:open).with("./translations/path_#{lang}.pres", "a")
          else
            File.should_not_receive(:open).with("./translations/path_#{lang}.pres", "a")
          end
        end
        Idiom::Yrb.new(:source => @source, :languages => @languages).generate
      end
    end
  end
  
  describe "yml" do
    before(:each) do
      @yml_file = <<-YAML
first: first key
second: second key
      YAML
      File.stub!(:readlines).and_return(@yml_file)
      Translate.stub!(:t).with("first key", "ENGLISH", anything).and_return("translated first key")
      Translate.stub!(:t).with("second key", "ENGLISH", anything).and_return("translated second key")
      @source = "./translations/path.yml"
    end
    
    it "should create the destination path if it does not exist" do
      Idiom::Yaml::LOCALES.each do |lang, code|
        FileUtils.should_receive(:mkdir_p).with("./translations") unless lang == "en-US"
      end
      Idiom::Yaml.new(:source => @source).generate
    end
    
    it "should write to the destination path" do
      Idiom::Yaml::LOCALES.each do |lang, code|
        File.should_receive(:open).with("./translations/path_#{lang}.yml", "a") unless lang == "en-US"
      end
      Idiom::Yaml.new(:source => @source).generate
    end

    describe "directories" do
      before(:each) do
        @source = "./translations/en-US/path.yml"
      end
          
      it "should write to directories" do
        Idiom::Yaml::LOCALES.each do |lang, code|
          File.should_receive(:open).with("./translations/#{lang}/path_#{lang}.yml", "a") unless lang == "en-US"
        end
        Idiom::Yaml.new(:source => @source, :use_dirs => true).generate
      end
    
      it "should create the destination path with directories if it does not exist" do
        Idiom::Yrb::LOCALES.each do |lang, code|
          FileUtils.should_receive(:mkdir_p).with("./translations/#{lang}") unless lang == "en-US"
        end
        Idiom::Yrb.new(:source => @source, :use_dirs => true).generate
      end
    end
    
    it "should translate the first string" do
      @file.should_receive(:puts).with(/first: translated first key/)
      Idiom::Yaml.new(:source => @source).generate
    end
    
    it "should translate the second string" do
      @file.should_receive(:puts).with(/second: translated second key/)
      Idiom::Yaml.new(:source => @source).generate
    end
    
    # describe "key exists" do
    #   before(:each) do
    #     Dir.stub!(:[]).and_return(["./translations/path_lang-CODE.yml"])
    #     File.should_receive(:exists?).with("./translations/path_lang-CODE.yml").and_return(true)
    #     YAML.should_receive(:load_file).and_return({"first" => "old translated first key"})
    #   end
    #   
    #   it "should not translate a key that is already translated" do
    #     @file.should_not_receive(:puts).with(/first: translated first key/)
    #     Idiom::Yaml.new(:source => @source).generate
    #   end
    #   
    #   it "should translate a key that is already translated if overwrite is true" do
    #     @file.should_receive(:puts).with(/first: translated first key/)
    #     Idiom::Yaml.new(:source => @source, :overwrite => true).generate
    #   end
    # end
    
    describe "languages" do
      it "should only translate the specified set of languages" do
        @languages = ["de-DE", "zh-Hant-HK"]
        Idiom::Yaml::LOCALES.each do |lang, code|
          if @languages.include?(lang)
            File.should_receive(:open).with("./translations/path_#{lang}.yml", "a")
          else
            File.should_not_receive(:open).with("./translations/path_#{lang}.yml", "a")
          end
        end
        Idiom::Yaml.new(:source => @source, :languages => @languages).generate
      end
    end
  end
end
