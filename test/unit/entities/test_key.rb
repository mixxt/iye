# encoding: utf-8

require "test_helper"
require "i18n_yaml_editor/entities/key"

class TestKey < Minitest::Test
  def setup
    @key = I18nYamlEditor::Key.new(id: "session.login")
  end

  def test_name
    assert_equal @key.name, @key.id
  end

end
