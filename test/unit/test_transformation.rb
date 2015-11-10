# encoding: utf-8

require "test_helper"
require "i18n_yaml_editor/transformation"

class TestTransformation < Minitest::Test
  def test_flatten_hash
    input = {
      "da" => {
        "session" => {"login" => "Log ind", "logout" => "Log ud"}
      },
      "en" => {
        "session" => {"login" => "Log in", "logout" => "Log out"}
      }
    }
    expected = {
      "da.session.login" => "Log ind",
      "da.session.logout" => "Log ud",
      "en.session.login" => "Log in",
      "en.session.logout" => "Log out"
    }

    assert_equal expected, Transformation.flatten_hash(input)
  end

  def test_nest_hash
    input = {
      "da.session.login" => "Log ind",
      "da.session.logout" => "Log ud",
      "en.session.login" => "Log in",
      "en.session.logout" => "Log out"
    }
    expected = {
      "da" => {
        "session" => {"login" => "Log ind", "logout" => "Log ud"}
      },
      "en" => {
        "session" => {"login" => "Log in", "logout" => "Log out"}
      }
    }

    assert_equal expected, Transformation.nest_hash(input)
  end

  def test_nested_hash_to_yaml_sorts_keys
    input = {
        "en.b" => "banana",
        "en.d" => "date",
        "en.c" => "chili",
        "en.a" => "avocado",
    }
    expected = <<-YAML
---
en:
  a: avocado
  b: banana
  c: chili
  d: date
    YAML

    assert_equal expected, Transformation.nest_hash(input).to_yaml
  end
end
