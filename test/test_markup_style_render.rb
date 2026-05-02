require 'minitest/autorun'
require_relative '../lib/Models/Paragraph'
require_relative '../lib/Parsers/MarkupStyleRender'

class TestMarkupStyleRender < Minitest::Test
  def test_paragraph_without_markups
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "Simple text",
      "markups" => []
    }, "post123")

    render = MarkupStyleRender.new(paragraph, false)
    result = render.parse

    assert_equal "Simple text", result
  end

  def test_handles_chinese_text_without_markups
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "纯中文文本",
      "markups" => []
    }, "post123")

    render = MarkupStyleRender.new(paragraph, false)
    result = render.parse

    assert_equal "纯中文文本", result
  end

  def test_handles_japanese_text_without_markups
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "日本語テキスト",
      "markups" => []
    }, "post123")

    render = MarkupStyleRender.new(paragraph, false)
    result = render.parse

    assert_equal "日本語テキスト", result
  end

  def test_handles_emoji_without_markups
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "Hello 🎉 World ✨",
      "markups" => []
    }, "post123")

    render = MarkupStyleRender.new(paragraph, false)
    result = render.parse

    assert_equal "Hello 🎉 World ✨", result
  end

  def test_handles_mixed_multilingual_text
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "Hello 你好 مرحبا 🎉",
      "markups" => []
    }, "post123")

    render = MarkupStyleRender.new(paragraph, false)
    result = render.parse

    assert_equal "Hello 你好 مرحبا 🎉", result
  end

  def test_handles_arabic_text
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "مرحبا بالعالم",
      "markups" => []
    }, "post123")

    render = MarkupStyleRender.new(paragraph, false)
    result = render.parse

    assert_equal "مرحبا بالعالم", result
  end

  def test_handles_hebrew_text
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "שלום עולם",
      "markups" => []
    }, "post123")

    render = MarkupStyleRender.new(paragraph, false)
    result = render.parse

    assert_equal "שלום עולם", result
  end

  def test_handles_arabic_with_markup
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "نص عربي bold",
      "markups" => [
        { "type" => "STRONG", "start" => 8, "end" => 12 }
      ]
    }, "post123")

    render = MarkupStyleRender.new(paragraph, false)
    result = render.parse

    assert_match /نص عربي/, result
    assert_match /\*\*bold\*\*/, result
  end

  def test_strong_markup
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "bold text",
      "markups" => [
        { "type" => "STRONG", "start" => 0, "end" => 4 }
      ]
    }, "post123")

    render = MarkupStyleRender.new(paragraph, false)
    result = render.parse

    assert_equal "**bold** text", result
  end

  def test_em_markup
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "italic text",
      "markups" => [
        { "type" => "EM", "start" => 0, "end" => 6 }
      ]
    }, "post123")

    render = MarkupStyleRender.new(paragraph, false)
    result = render.parse

    assert_equal "_italic_ text", result
  end

  def test_code_markup
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "code here",
      "markups" => [
        { "type" => "CODE", "start" => 0, "end" => 4 }
      ]
    }, "post123")

    render = MarkupStyleRender.new(paragraph, false)
    result = render.parse

    assert_equal "`code` here", result
  end
end