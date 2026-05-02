require 'minitest/autorun'
require_relative '../lib/Models/Paragraph'
require_relative '../lib/Parsers/H1Parser'
require_relative '../lib/Parsers/H2Parser'
require_relative '../lib/Parsers/H3Parser'
require_relative '../lib/Parsers/PParser'
require_relative '../lib/Parsers/BQParser'

class TestParsers < Minitest::Test
  def test_h1_parser_converts_heading
    paragraph = Paragraph.new({
      "name" => "h1_1",
      "type" => "H1",
      "text" => "Main Title"
    }, "post123")

    parser = H1Parser.new
    result = parser.parse(paragraph)

    assert_equal "# Main Title", result.strip
  end

  def test_h1_parser_handles_chinese
    paragraph = Paragraph.new({
      "name" => "h1_1",
      "type" => "H1",
      "text" => "中文标题"
    }, "post123")

    parser = H1Parser.new
    result = parser.parse(paragraph)

    assert_equal "# 中文标题", result.strip
  end

  def test_h2_parser_converts_heading
    paragraph = Paragraph.new({
      "name" => "h2_1",
      "type" => "H2",
      "text" => "Sub Title"
    }, "post123")

    parser = H2Parser.new
    result = parser.parse(paragraph)

    assert_equal "## Sub Title", result.strip
  end

  def test_h3_parser_converts_heading
    paragraph = Paragraph.new({
      "name" => "h3_1",
      "type" => "H3",
      "text" => "Section Title"
    }, "post123")

    parser = H3Parser.new
    result = parser.parse(paragraph)

    assert_equal "### Section Title", result.strip
  end

  def test_p_parser_converts_paragraph
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "This is a paragraph."
    }, "post123")

    parser = PParser.new
    result = parser.parse(paragraph)

    assert_equal "This is a paragraph.", result.strip
  end

  def test_p_parser_handles_multiline
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "Line 1\nLine 2\nLine 3"
    }, "post123")

    parser = PParser.new
    result = parser.parse(paragraph)

    assert_equal "Line 1\nLine 2\nLine 3", result.strip
  end

  def test_bq_parser_converts_blockquote
    paragraph = Paragraph.new({
      "name" => "bq_1",
      "type" => "BQ",
      "text" => "This is a quote."
    }, "post123")

    parser = BQParser.new
    result = parser.parse(paragraph)

    assert_match /> This is a quote\./, result
  end

  def test_bq_parser_handles_multiline_quotes
    paragraph = Paragraph.new({
      "name" => "bq_1",
      "type" => "BQ",
      "text" => "Line 1\nLine 2"
    }, "post123")

    parser = BQParser.new
    result = parser.parse(paragraph)

    assert_match /> Line 1/, result
    assert_match /> Line 2/, result
  end

  def test_bq_parser_handles_non_latin_text
    paragraph = Paragraph.new({
      "name" => "bq_1",
      "type" => "BQ",
      "text" => "引用中文内容"
    }, "post123")

    parser = BQParser.new
    result = parser.parse(paragraph)

    assert_match /> 引用中文内容/, result
  end

  def test_p_parser_handles_arabic
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "مرحبا بالعالم"
    }, "post123")

    parser = PParser.new
    result = parser.parse(paragraph)

    assert_match /مرحبا/, result
  end

  def test_p_parser_handles_hebrew
    paragraph = Paragraph.new({
      "name" => "p_1",
      "type" => "P",
      "text" => "שלום עולם"
    }, "post123")

    parser = PParser.new
    result = parser.parse(paragraph)

    assert_match /שלום/, result
  end

  def test_h1_parser_handles_arabic
    paragraph = Paragraph.new({
      "name" => "h1_1",
      "type" => "H1",
      "text" => "عنوان عربي"
    }, "post123")

    parser = H1Parser.new
    result = parser.parse(paragraph)

    assert_match /عنوان عربي/, result
  end
end