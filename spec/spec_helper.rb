require 'attributer'

def local_test_file
  path = File.realpath("spec/test.html")
  string = File.open(path, "rb").read
  string.force_encoding "UTF-8"
end

def results_file
  path = File.realpath("spec/results.html")
  string = File.open(path, "rb").read
end

def local_test_file_2
  path = File.realpath("spec/test2.html")
  string = File.open(path, "rb").read
  string.force_encoding "UTF-8"
end