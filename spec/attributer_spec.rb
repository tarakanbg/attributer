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

    it "should handle domains" do
      test_string = '<img alt="1" class="gallery" src="/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg">'
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

    it "should produce matching results" do
      local_test_file.image_attributes(:domain => "http://darvazaogrev.com").should eq(results_file)
    end  

    it "should handle HTML with or without trailing slashes in the img tag" do
      local_test_file_2.image_attributes(:domain => "http://darvazaogrev.com").should eq(results_file)
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

    it "should sub old with new" do
      old_htmls = []; new_htmls = [] 
      parsed = Nokogiri::HTML::DocumentFragment.parse(local_test_file)
      images = parsed.css("img")
      images.each {|i| old_htmls << i.to_html}
      for image in old_htmls
        imagetag = Nokogiri::HTML::DocumentFragment.parse( image )
        img = imagetag.at_css "img"
        domain = "http://darvazaogrev.com"
        path = domain + img['src']
        size = FastImage.size(path, :timeout => 5)
        img['width'] = size.first.to_s
        img['height'] = size.last.to_s
        new_htmls << imagetag.to_html
      end
      new_htmls.should eq(["<img alt=\"1\" class=\"gallery\" src=\"/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg\" width=\"200\" height=\"266\">", "<img alt=\"2\" class=\"gallery\" src=\"/assets/thumbnails/2-413bd5c8b6b7263beffbbbad112568fd.jpg\" width=\"200\" height=\"266\">", "<img alt=\"3\" class=\"gallery\" src=\"/assets/thumbnails/3-50cea3d1ecb37bc0a7158adfee38d020.jpg\" width=\"200\" height=\"266\">", "<img alt=\"4\" class=\"gallery\" src=\"/assets/thumbnails/4-a958b0ef2ef3ef8419736ef9aa5f9f6a.jpg\" width=\"200\" height=\"266\">", "<img alt=\"5\" class=\"gallery\" src=\"/assets/thumbnails/5-900f1e2e061af1ea2f0ea622d0be5c38.jpg\" width=\"200\" height=\"266\">", "<img alt=\"6\" class=\"gallery\" src=\"/assets/thumbnails/6-4837c7ac224fc26dd995f4441aa7a458.jpg\" width=\"200\" height=\"266\">", "<img alt=\"7\" class=\"gallery\" src=\"/assets/thumbnails/7-79120b81863981edf1a997711e8268fb.jpg\" width=\"200\" height=\"266\">", "<img alt=\"8\" class=\"gallery\" src=\"/assets/thumbnails/8-2057ca29648dc1530b752918f09fba8d.jpg\" width=\"200\" height=\"266\">", "<img alt=\"9\" class=\"gallery\" src=\"/assets/thumbnails/9-413bd5c8b6b7263beffbbbad112568fd.jpg\" width=\"200\" height=\"266\">", "<img alt=\"10\" class=\"gallery\" src=\"/assets/thumbnails/10-900f1e2e061af1ea2f0ea622d0be5c38.jpg\" width=\"200\" height=\"266\">", "<img alt=\"11\" class=\"gallery\" src=\"/assets/thumbnails/11-900f1e2e061af1ea2f0ea622d0be5c38.jpg\" width=\"200\" height=\"266\">", "<img alt=\"12\" class=\"gallery\" src=\"/assets/thumbnails/12-a958b0ef2ef3ef8419736ef9aa5f9f6a.jpg\" width=\"200\" height=\"266\">", "<img alt=\"13\" class=\"gallery\" src=\"/assets/thumbnails/13-4837c7ac224fc26dd995f4441aa7a458.jpg\" width=\"200\" height=\"266\">", "<img alt=\"14\" class=\"gallery\" src=\"/assets/thumbnails/14-79120b81863981edf1a997711e8268fb.jpg\" width=\"200\" height=\"266\">", "<img alt=\"15\" class=\"gallery\" src=\"/assets/thumbnails/15-51330c678115d1236ce46e1ea8e6c019.jpg\" width=\"200\" height=\"267\">", "<img alt=\"16\" class=\"gallery\" src=\"/assets/thumbnails/16-1883f9ecb69aebe721037b4b19c6cec4.jpg\" width=\"200\" height=\"267\">", "<img alt=\"17\" class=\"gallery\" src=\"/assets/thumbnails/17-7b163458e971099e316f1d28f686b01a.jpg\" width=\"200\" height=\"267\">", "<img alt=\"18\" class=\"gallery\" src=\"/assets/thumbnails/18-c2b893d1a1b624bf740afebf1464d78d.jpg\" width=\"200\" height=\"267\">", "<img alt=\"19\" class=\"gallery\" src=\"/assets/thumbnails/19-6ea454cbc4a895408c9ad38dd8edce4e.jpg\" width=\"200\" height=\"267\">", "<img alt=\"20\" class=\"gallery\" src=\"/assets/thumbnails/20-7edabdea6a94e8b70ffc37ee324b9fab.jpg\" width=\"200\" height=\"267\">"])
      old_htmls.should eq(["<img alt=\"1\" class=\"gallery\" src=\"/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg\">", "<img alt=\"2\" class=\"gallery\" src=\"/assets/thumbnails/2-413bd5c8b6b7263beffbbbad112568fd.jpg\">", "<img alt=\"3\" class=\"gallery\" src=\"/assets/thumbnails/3-50cea3d1ecb37bc0a7158adfee38d020.jpg\">", "<img alt=\"4\" class=\"gallery\" src=\"/assets/thumbnails/4-a958b0ef2ef3ef8419736ef9aa5f9f6a.jpg\">", "<img alt=\"5\" class=\"gallery\" src=\"/assets/thumbnails/5-900f1e2e061af1ea2f0ea622d0be5c38.jpg\">", "<img alt=\"6\" class=\"gallery\" src=\"/assets/thumbnails/6-4837c7ac224fc26dd995f4441aa7a458.jpg\">", "<img alt=\"7\" class=\"gallery\" src=\"/assets/thumbnails/7-79120b81863981edf1a997711e8268fb.jpg\">", "<img alt=\"8\" class=\"gallery\" src=\"/assets/thumbnails/8-2057ca29648dc1530b752918f09fba8d.jpg\">", "<img alt=\"9\" class=\"gallery\" src=\"/assets/thumbnails/9-413bd5c8b6b7263beffbbbad112568fd.jpg\">", "<img alt=\"10\" class=\"gallery\" src=\"/assets/thumbnails/10-900f1e2e061af1ea2f0ea622d0be5c38.jpg\">", "<img alt=\"11\" class=\"gallery\" src=\"/assets/thumbnails/11-900f1e2e061af1ea2f0ea622d0be5c38.jpg\">", "<img alt=\"12\" class=\"gallery\" src=\"/assets/thumbnails/12-a958b0ef2ef3ef8419736ef9aa5f9f6a.jpg\">", "<img alt=\"13\" class=\"gallery\" src=\"/assets/thumbnails/13-4837c7ac224fc26dd995f4441aa7a458.jpg\">", "<img alt=\"14\" class=\"gallery\" src=\"/assets/thumbnails/14-79120b81863981edf1a997711e8268fb.jpg\">", "<img alt=\"15\" class=\"gallery\" src=\"/assets/thumbnails/15-51330c678115d1236ce46e1ea8e6c019.jpg\">", "<img alt=\"16\" class=\"gallery\" src=\"/assets/thumbnails/16-1883f9ecb69aebe721037b4b19c6cec4.jpg\">", "<img alt=\"17\" class=\"gallery\" src=\"/assets/thumbnails/17-7b163458e971099e316f1d28f686b01a.jpg\">", "<img alt=\"18\" class=\"gallery\" src=\"/assets/thumbnails/18-c2b893d1a1b624bf740afebf1464d78d.jpg\">", "<img alt=\"19\" class=\"gallery\" src=\"/assets/thumbnails/19-6ea454cbc4a895408c9ad38dd8edce4e.jpg\">", "<img alt=\"20\" class=\"gallery\" src=\"/assets/thumbnails/20-7edabdea6a94e8b70ffc37ee324b9fab.jpg\">"])
      new_post = local_test_file.force_encoding "UTF-8"
      new_post.should eq(local_test_file)
      old_htmls.first.should eq("<img alt=\"1\" class=\"gallery\" src=\"/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg\">")
      new_htmls.first.should eq("<img alt=\"1\" class=\"gallery\" src=\"/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg\" width=\"200\" height=\"266\">")
      old_htmls.each do |image|
        image.sub!(">", " />") unless new_post.include? image
        image.sub!(" />", "/>") unless new_post.include? image        
      end
      old_htmls.first.should eq("<img alt=\"1\" class=\"gallery\" src=\"/assets/thumbnails/1-2057ca29648dc1530b752918f09fba8d.jpg\" />")
      new_post.include?(old_htmls.first).should be(true)
      old_htmls.each do |old|        
        new_post.sub!(old, new_htmls.shift)                
      end
      new_post.should eq(results_file)
    end
  end  


end