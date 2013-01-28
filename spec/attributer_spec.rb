require 'spec_helper.rb'

local_test_file

describe String do

  describe "local_test_file" do
    it "should return a string" do
      local_test_file.class.should eq(String)     
    end  
    it "should be read corectly" do
      local_test_file.should eq(File.open(File.realpath("spec/test.html"), "rb").read)     
    end     
  end

  describe "image_attributes" do
    it "should return a string" do
      local_test_file.image_attributes(:domain => "http://darvazaogrev.com").class.should eq(String)
    end  

    it "should produce matching results" do
      test_string = "<img alt=\"1\" class=\"gallery\" src=\"/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg\">"
      test_string.image_attributes(:domain => "http://darvazaogrev.com").should eq("<img alt=\"1\" class=\"gallery\" src=\"/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg\" width=\"200\" height=\"266\">")      
    end

    it "should raise exception if used without args" do
      test_string = "<img alt=\"1\" class=\"gallery\" src=\"/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg\">"
      expect {test_string.image_attributes}.to raise_error(ArgumentError)
    end

    it "should handle local path" do
      path = File.realpath("spec")
      test_string = "<img alt=\"test\" src=\"/test.png\">"
      test_string.image_attributes(:path => path).should eq("<img alt=\"test\" src=\"/test.png\" width=\"500\" height=\"333\">")
    end      
  end

end


describe Attributer::Attributer do

  describe "parsing the html block" do
    it "should be successful" do
      parsed = Nokogiri::HTML::DocumentFragment.parse(local_test_file)
      parsed.class.should eq(Nokogiri::HTML::DocumentFragment)      
      images = parsed.css("img")
      images.class.should eq(Nokogiri::XML::NodeSet)
      images.count.should eq(20)      
    end

    it "should yield a valid array of img tags" do
      old_htmls = []; new_htmls = [] 
      parsed = Nokogiri::HTML::DocumentFragment.parse(local_test_file)
      parsed.class.should eq(Nokogiri::HTML::DocumentFragment)      
      images = parsed.css("img")
      images.class.should eq(Nokogiri::XML::NodeSet)
      images.count.should eq(20)   
      images.each {|i| old_htmls << i.to_html}
      old_htmls.count.should eq(20)
      old_htmls.class.should eq(Array)
      old_htmls.first.should eq("<img alt=\"1\" class=\"gallery\" src=\"/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg\">")
      old_htmls.last.should eq("<img alt=\"20\" class=\"gallery\" src=\"/assets/thumbnails/20-7edabdea6a94e8b70ffc37ee324b9fab.jpg\">")
    end

    it "should parse down to XML element" do
      old_htmls = []; new_htmls = [] 
      parsed = Nokogiri::HTML::DocumentFragment.parse(local_test_file)
      images = parsed.css("img")
      images.each {|i| old_htmls << i.to_html}
      imagetag = Nokogiri::HTML::DocumentFragment.parse( old_htmls.first )
      imagetag.class.should eq(Nokogiri::HTML::DocumentFragment)
      img = imagetag.at_css "img"
      img.class.should eq(Nokogiri::XML::Element)
      img['src'].class.should eq(String)
      img['src'].should eq("/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg")
    end

    it "should construct valid paths" do
      old_htmls = []; new_htmls = [] 
      parsed = Nokogiri::HTML::DocumentFragment.parse(local_test_file)
      images = parsed.css("img")
      images.each {|i| old_htmls << i.to_html}
      imagetag = Nokogiri::HTML::DocumentFragment.parse( old_htmls.first )
      img = imagetag.at_css "img"
      img['src'].class.should eq(String)
      domain = "http://darvazaogrev.com"
      path = domain + img['src']
      path.should eq("http://darvazaogrev.com/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg")
    end

    it "should pull dimensions" do
      old_htmls = []; new_htmls = [] 
      parsed = Nokogiri::HTML::DocumentFragment.parse(local_test_file)
      images = parsed.css("img")
      images.each {|i| old_htmls << i.to_html}
      imagetag = Nokogiri::HTML::DocumentFragment.parse( old_htmls.first )
      img = imagetag.at_css "img"
      domain = "http://darvazaogrev.com"
      path = domain + img['src']
      size = FastImage.size(path)
      size.should eq([200, 266])
      size.class.should eq(Array)
      img['width'] = size.first.to_s
      img['height'] = size.last.to_s
      imagetag.to_html.should eq("<img alt=\"1\" class=\"gallery\" src=\"/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg\" width=\"200\" height=\"266\">")
    end
  end  


end