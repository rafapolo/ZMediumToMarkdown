
$lib = File.expand_path('../', File.dirname(__FILE__))

require 'Models/Paragraph'

class MarkupStyleRender 
    attr_accessor :paragraph, :chars, :encodeType

    class TextChar
        attr_accessor :chars, :type
        def initialize(chars, type)
            @chars = chars
            @type = type
        end
    end

    class TagChar < TextChar
        attr_accessor :sort, :startIndex, :endIndex, :startChars, :endChars
        def initialize(sort, startIndex, endIndex, startChars, endChars)
            @sort = sort
            @startIndex = startIndex
            @endIndex = endIndex - 1
            @startChars = TextChar.new(startChars.chars, 'TagStart')
            @endChars = TextChar.new(endChars.chars, 'TagEnd')
        end
    end


    def initialize(paragraph)
        @paragraph = paragraph

        chars = {}
        index = 0
        
        paragraph.text.each_char do |char|
            chars[index] = TextChar.new([char], "Text")
            index += 1
            if char.bytes.length >= 4
                # some emoji need more space (in Medium)
                chars[index] = TextChar.new([], "Text")
                index += 1
            end
        end
        
        @chars = chars
    end

    def optimize(chars) 
        while true
            hasExcute = false
            
            index = 0
            startTagIndex = nil
            preTag = nil
            preTagIndex = nil
            preTextChar = nil
            preTextIndex = nil
            chars.each do |char|

                if !preTag.nil?
                    if preTag.type == "TagStart" && char.type == "TagEnd"
                        chars.delete_at(index)
                        chars.delete_at(preTagIndex)
                        hasExcute = true
                        break
                    end
                end
                
                if char.type == "TagStart" && (preTag == nil || preTag.type == "TagEnd" || preTag.type == "Text")
                    startTagIndex = index
                elsif (char.type  == "TagEnd" || char.type  == "Text") && startTagIndex != nil
                    if preTextChar != nil && preTextChar.chars.join() != "\n"
                        # not first tag & insert blank between start tag and before text
                        if preTextChar.chars.join() != " "
                            chars.insert(startTagIndex, TextChar.new(" ".chars, "Text"))
                            hasExcute = true
                            break
                        end
                    end
                    startTagIndex = nil
                end

                if !preTag.nil?
                    if preTag.type == "TagStart" && char.type  == "Text"
                        # delete blank between start tag and after text
                        if char.chars.join().strip == ""
                            chars.delete_at(index)
                            hasExcute = true
                            break
                        end
                    end

                    if preTag.type == "Text" && char.type  == "TagEnd"
                        if preTextChar.chars.join().strip == "" && preTextChar.chars.join() != "\n"
                            chars.delete_at(preTextIndex)
                            hasExcute = true
                            break
                        end
                    end

                    if preTag.type == "TagEnd" && char.type  == "Text"
                        if char.chars.join() != " "
                            chars.insert(index, TextChar.new(" ".chars, "Text"))
                            hasExcute = true
                            break
                        end
                    end

                end

                if char.type == "Text"
                    preTextChar = char
                    preTextIndex = index
                end
                
                preTag = char
                preTagIndex = index

                index += 1
            end
            
            if !hasExcute
                break
            end
        end

        chars
    end

    def parse()
        result = paragraph.text

        if !paragraph.markups.nil? && paragraph.markups.length > 0
            
            tags = []
            paragraph.markups.each do |markup|
                tag = nil
                if markup.type == "EM"
                    tag = TagChar.new(2, markup.start, markup.end, "_", "_")
                elsif markup.type == "CODE"
                    tag = TagChar.new(3, markup.start, markup.end, "`", "`")
                elsif markup.type == "STRONG"
                    tag = TagChar.new(2, markup.start, markup.end, "**", "**")
                elsif markup.type == "A"
                    url = markup.href
                    if markup.anchorType == "LINK"
                        url = markup.href
                    elsif markup.anchorType == "USER"
                        url = "https://medium.com/u/#{markup.userId}"
                    end
                    
                    tag = TagChar.new(1, markup.start, markup.end, "[", "](#{url})")
                else
                    Helper.makeWarningText("Undefined Markup Type: #{markup.type}.")
                end

                if !tag.nil?
                    tags.append(tag)
                end
            end

            tags.sort_by(&:startIndex)

            response = []
            stack = []

            chars.each do |index, char|

                if char.chars.join() == "\n"
                    brStack = stack.dup
                    while brStack.length > 0
                        tag = brStack.pop
                        response.push(tag.endChars)
                    end
                    response.append(TextChar.new(char.chars, 'Text'))
                    brStack = stack.dup.reverse
                    while brStack.length > 0
                        tag = brStack.pop
                        response.push(tag.startChars)
                    end
                end

                startTags = tags.select { |tag| tag.startIndex == index }.sort_by(&:sort)
                if !startTags.nil?
                    startTags.each do |tag|
                        response.append(tag.startChars)
                        stack.append(tag)
                    end
                end

                if char.chars.join() != "\n"
                    response.append(TextChar.new(char.chars, 'Text'))
                end

                endTags = tags.select { |tag| tag.endIndex == index }
                if !endTags.nil? && endTags.length > 0
                    mismatchTags = []
                    while endTags.length > 0
                        stackTag = stack.pop
                        stackTagInEndTagsIndex = endTags.find_index(stackTag)
                        if !stackTagInEndTagsIndex.nil?
                            # as expected
                            endTags.delete_at(stackTagInEndTagsIndex)
                        else
                            mismatchTags.append(stackTag)
                        end
                        response.append(stackTag.endChars)
                    end

                    while mismatchTags.length > 0
                        mismatchTag = mismatchTags.pop
                        response.append(mismatchTag.startChars)
                        stack.append(mismatchTag)
                    end
                end
            end

            while stack.length > 0
                tag = stack.pop
                response.push(tag.endChars)
            end
            
            response = optimize(response)
            result = response.map{ |response| response.chars }.join()
        end

        result
    end

end