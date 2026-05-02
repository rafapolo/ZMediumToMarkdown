require 'minitest/autorun'
require_relative '../lib/Request'

class TestRequestEncoding < Minitest::Test
  def test_encode_to_utf8_handles_nil
    result = Request.encode_to_utf8(nil)
    assert_nil result
  end

  def test_encode_to_utf8_handles_empty_string
    result = Request.encode_to_utf8("")
    assert_equal "", result
  end

  def test_encode_to_utf8_handles_ascii
    result = Request.encode_to_utf8("Hello World")
    assert_equal "Hello World", result
    assert result.valid_encoding?
  end

  def test_encode_to_utf8_handles_chinese
    result = Request.encode_to_utf8("你好世界")
    assert_equal "你好世界", result
    assert result.valid_encoding?
  end

  def test_encode_to_utf8_handles_japanese
    result = Request.encode_to_utf8("こんにちは世界")
    assert_equal "こんにちは世界", result
    assert result.valid_encoding?
  end

  def test_encode_to_utf8_handles_korean
    result = Request.encode_to_utf8("안녕하세요")
    assert_equal "안녕하세요", result
    assert result.valid_encoding?
  end

  def test_encode_to_utf8_handles_arabic
    result = Request.encode_to_utf8("مرحبا بالعالم")
    assert_equal "مرحبا بالعالم", result
    assert result.valid_encoding?
  end

  def test_encode_to_utf8_handles_hebrew
    result = Request.encode_to_utf8("שלום עולם")
    assert_equal "שלום עולם", result
    assert result.valid_encoding?
  end

  def test_encode_to_utf8_handles_rtl_mixed
    result = Request.encode_to_utf8("Hello مرحبا שלום 你好")
    assert_equal "Hello مرحبا שלום 你好", result
    assert result.valid_encoding?
  end

  def test_encode_to_utf8_preserves_arabic_diacritics
    result = Request.encode_to_utf8("مُحَمَّدٌ")
    assert_equal "مُحَمَّدٌ", result
    assert result.valid_encoding?
  end

  def test_encode_to_utf8_handles_cyrillic
    result = Request.encode_to_utf8("Привет мир")
    assert_equal "Привет мир", result
    assert result.valid_encoding?
  end

  def test_encode_to_utf8_handles_emoji
    result = Request.encode_to_utf8("🎉🚀✨")
    assert_equal "🎉🚀✨", result
    assert result.valid_encoding?
  end

  def test_encode_to_utf8_handles_mixed_content
    result = Request.encode_to_utf8("Hello 你好 こんにちは مرحبا 🎉")
    assert_equal "Hello 你好 こんにちは مرحبا 🎉", result
    assert result.valid_encoding?
  end

  def test_encode_to_utf8_preserves_special_characters
    special_chars = "!<>\"'&()+=?#@$%^*~`"
    result = Request.encode_to_utf8(special_chars)
    assert_equal special_chars, result
    assert result.valid_encoding?
  end

  def test_encode_to_utf8_handles_newlines_and_tabs
    content = "Line1\nLine2\tTabbed"
    result = Request.encode_to_utf8(content)
    assert_equal content, result
    assert result.valid_encoding?
  end

  def test_detect_encoding_returns_nil_for_empty_body
    assert_nil Request.detect_encoding("")
    assert_nil Request.detect_encoding(nil)
  end

  def test_detect_encoding_finds_utf8_in_charset
    body = '<html><head><meta charset="UTF-8"></head></html>'
    encoding = Request.detect_encoding(body)
    assert_equal "UTF-8", encoding
  end

  def test_detect_encoding_finds_iso8859_in_charset
    body = '<html><head><meta charset="ISO-8859-1"></head></html>'
    encoding = Request.detect_encoding(body)
    assert_equal "ISO-8859-1", encoding
  end
end