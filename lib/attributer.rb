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

    attributes = %w{lpost images old_htmls new_htmls domain new_post}
    attributes.each {|attribute| attr_accessor attribute.to_sym }
    
    def initialize(string, args = nil)      
      args[:domain].empty? ? @domain = "" : @domain = args[:domain]
      # @domain = ""
      # @domain = args[:domain] if args[:domain]
      @lpost = Nokogiri::HTML::DocumentFragment.parse( string.force_encoding "UTF-8" )
      @new_post = string.force_encoding "UTF-8"
      @old_htmls = []; @new_htmls = []
      @images = @lpost.css("img")
      @images.each {|i| @old_htmls << i.to_html}
      add_attributes  
      replace_images    
    end

    def parsed_string
      @new_post
    end

  private

    def add_attributes
      for image in @old_htmls
        imagetag = Nokogiri::HTML::DocumentFragment.parse( image )
        img = imagetag.at_css "img"
        size = FastImage.size(@domain + img['src'], :timeout => 5)
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

  end
end
