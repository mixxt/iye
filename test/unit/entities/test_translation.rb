# encoding: utf-8

require "test_helper"
require "i18n_yaml_editor/entities/translation"

class TestTranslation < Minitest::Test
  def test_text
    translation = Translation.new(value: "Some string")
    assert_equal "Some string", translation.text
  end

  def test_nil_value_is_blank_text
    translation = Translation.new(value: nil)
    assert translation.text_blank?
  end

  def test_empty_value_is_blank_text
    translation = Translation.new(value: "")
    assert translation.text_blank?
  end

  def test_space_value_is_blank_text
    translation = Translation.new(value: " ")
    assert translation.text_blank?
  end

  def test_tab_value_is_blank_text
    translation = Translation.new(value: "\t")
    assert translation.text_blank?
  end

  def test_array_value_is_array
    translation = Translation.new(value: %w(a b c))
    assert_equal %w(a b c), translation.value
  end

  def test_text_normalize_newlines
    translation = Translation.new(value: "foo\r\nbar")
    assert_equal "foo\nbar", translation.text
  end

  def test_number_of_lines_nil
    translation = Translation.new(value: nil)
    assert_equal 1, translation.number_of_lines
  end

  def test_number_of_lines_single_line
    translation = Translation.new(value: "foo")
    assert_equal 1, translation.number_of_lines
  end

  def test_number_of_lines_multiple_lines
    translation = Translation.new(value: "foo\nbar\nbaz")
    assert_equal 3, translation.number_of_lines
  end

  def test_id_construction
    translation = Translation.new(locale_id: "da", key_id: "session.login")
    assert_equal "da.session.login", translation.id
  end
end
