require 'minitest/autorun'
require_relative '../lib/Models/Paragraph'

class TestParagraph < Minitest::Test
  def test_paragraph_creation
    paragraph_data = {
      "name" => "paragraph1",
      "type" => "P",
      "text" => "Hello World",
      "markups" => []
    }
    paragraph = Paragraph.new(paragraph_data, "post123")

    assert_equal "paragraph1", paragraph.name
    assert_equal "P", paragraph.type
    assert_equal "Hello World", paragraph.text
    assert_equal "post123", paragraph.postID
  end

  def test_paragraph_handles_chinese_text
    paragraph_data = {
      "name" => "paragraph1",
      "type" => "P",
      "text" => "你好世界",
      "markups" => []
    }
    paragraph = Paragraph.new(paragraph_data, "post123")

    assert_equal "你好世界", paragraph.text
  end

  def test_paragraph_handles_emoji
    paragraph_data = {
      "name" => "paragraph1",
      "type" => "P",
      "text" => "Hello 🎉 World",
      "markups" => []
    }
    paragraph = Paragraph.new(paragraph_data, "post123")

    assert_equal "Hello 🎉 World", paragraph.text
  end

  def test_paragraph_with_markups
    markups = [
      { "type" => "STRONG", "start" => 0, "end" => 5 }
    ]
    paragraph_data = {
      "name" => "paragraph1",
      "type" => "P",
      "text" => "Hello World",
      "markups" => markups
    }
    paragraph = Paragraph.new(paragraph_data, "post123")

    assert_equal 1, paragraph.markups.length
    assert_equal "STRONG", paragraph.markups.first.type
  end

  def test_paragraph_with_empty_text
    paragraph_data = {
      "name" => "paragraph1",
      "type" => "P",
      "text" => "",
      "markups" => []
    }
    paragraph = Paragraph.new(paragraph_data, "post123")

    assert_equal "", paragraph.text
  end
end