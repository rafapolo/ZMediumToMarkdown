$lib = File.expand_path('../', File.dirname(__FILE__))

require "Parsers/Parser"
require 'Models/Paragraph'

require 'ImageDownloader'
require 'PathPolicy'

class IMGParser < Parser
    attr_accessor :nextParser, :pathPolicy
    def parse(paragraph)
        if paragraph.type == 'IMG'

            fileName = paragraph.metadata.id #d*fsafwfe.jpg

            imageURL = "https://miro.medium.com/max/1400/#{paragraph.metadata.id}"

            imagePathPolicy = PathPolicy.new(pathPolicy.getAbsolutePath(nil), paragraph.postID)
            absolutePath = imagePathPolicy.getAbsolutePath(fileName)
            
            comment = ""
            if paragraph.text != ""
                comment = " \"#{paragraph.text}\""
            end

            if  ImageDownloader.download(absolutePath, imageURL)
                relativePath = "#{pathPolicy.getRelativePath(nil)}/#{imagePathPolicy.getRelativePath(fileName)}"
                "![#{paragraph.text}](/#{relativePath}#{comment})"
            else
                "![#{paragraph.text}](#{imageURL}#{comment})"
            end
        else
            if !nextParser.nil?
                nextParser.parse(paragraph)
            end
        end
    end
end
