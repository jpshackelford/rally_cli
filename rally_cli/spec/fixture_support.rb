module FixtureSupport
  
  # return the contents of a fixture file.
  def fixture(file)
    File.open(fixture_path(file),'rb'){|f| f.read}
  end
  
  # return a REXML document for a fixture file.
  def xml_fixture(file)
    return REXML::Document.new(fixture(file))
  end
  
  def yml_fixture(file)
    return YAML.load( fixture(file + '.yml'))  
  end
  
  # path to a file in the fixtures directory
  def fixture_path(filename)
    return File.join(File.dirname(__FILE__), '..', 'fixtures', filename)
  end
  
  # path to a file in the output directory
  def output_path(filename) 
    out_path = File.join(File.dirname(__FILE__), '..', 'test_output')  
    begin
      FileUtils.mkdir(out_path)
    rescue SystemCallError
      # ignore the error if the directory already exists
    end
    return File.join(out_path, filename)
  end
  
  # write file in the test output directory 
  def write_test_output(file,data)
    File.open(output_path(file),'wb'){|f| f.write(data)}
    return File.open(output_path(file),'rb'){|f| f.read}
  end
  
end