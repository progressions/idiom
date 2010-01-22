def stub_io
  stub_screen_io
  stub_file_io
  stub_file_utils
  stub_yaml
  stub_yrb
  stub_growl
end

def stub_screen_io
  $stdout.stub!(:puts)
  $stdout.stub!(:print)    
end

def stub_file_io(unprocessed_file="")
  @file ||= mock('file').as_null_object
  @file.stub!(:read).and_return(unprocessed_file)
  @file.stub!(:write)
  @file.stub!(:puts)
  
  File.stub!(:new).and_return(@file)
  File.stub!(:exists?).and_return(false)
  File.stub!(:open).and_yield(@file) 
  File.stub!(:read).and_return(unprocessed_file)
  File.stub!(:readlines).and_return(["first\n", "second\n"])
end

def stub_file_utils
  FileUtils.stub!(:rm)
  FileUtils.stub!(:rm_rf)
  FileUtils.stub!(:cp_r)
  FileUtils.stub!(:mkdir_p)
end

def stub_yaml(output_hash={})
  YAML.stub!(:load_file).and_return(output_hash)
end

def stub_yrb(output_hash={})
  YRB.stub!(:load_file).and_return(output_hash)
end

def stub_timer
  @timer = mock('timer').as_null_object
  @timer.stub!(:time).and_yield
  Timer.stub!(:new).and_return(@timer)
end

def stub_growl
  @g = Object.new
  Growl.stub(:new).and_return(@g)
  @g.stub(:notify).as_null_object  
end

def reset_constant(constant, value)
  Object.send(:remove_const, constant)
  Object.const_set(constant, value)
end
