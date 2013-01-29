require "attributer/version"

class String
  def image_attributes(args={})    
    Attributer::Attributer.new(self, args).parsed_string
  end
end

module Attributer
  class Attributer
    require "fastimage"
    require "nokogiri"

    attributes = %w{lpost images old_htmls new_htmls uri new_post}
    attributes.each {|attribute| attr_accessor attribute.to_sym }
    
    def initialize(string, args = nil)      
      args[:domain] ? @uri = args[:domain] : @uri = args[:path]
      raise ArgumentError, "No domain or local path specified! Attributer can't find image!\nPlease use either :domain or :path options in your\n'image_attributes' method!" if @uri.nil?
      @lpost = Nokogiri::HTML::DocumentFragment.parse( string.force_encoding "UTF-8" )
      @new_post = string.force_encoding "UTF-8"
      parse_image_tags      
      add_attributes  
      replace_images    
    end

    def parsed_string
      @new_post
    end

  private

    def parse_image_tags
      @old_htmls = []; @new_htmls = []
      @images = @lpost.css("img")
      @images.each {|i| @old_htmls << i.to_html}
      process_trailing_slashes
    end

    def add_attributes
      for image in @old_htmls
        imagetag = Nokogiri::HTML::DocumentFragment.parse( image )
        img = imagetag.at_css "img"
        size = FastImage.size(@uri + img['src'], :timeout => 5)
        img['width'] = size.first.to_s
        img['height'] = size.last.to_s
        @new_htmls << imagetag.to_html
      end
    end

    def replace_images
      @old_htmls.each do |old|
        @new_post.sub!(old, @new_htmls.shift)                
      end      
    end

    def process_trailing_slashes
      @old_htmls.each do |image|
        image.sub!(">", " />") unless @new_post.include? image
        image.sub!(" />", "/>") unless @new_post.include? image        
      end
    end

  end
end
