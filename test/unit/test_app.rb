# encoding: utf-8

require "test_helper"
require "i18n_yaml_editor/app"

class TestApp < Minitest::Test
  include FixtureHelpers

  def setup
    @dir = setup_fixture_dir('simple')
    @store_mock = Minitest::Mock.new
  end

  def test_populate_store
    data = {
        "#{@dir}/de.yml" => {
            'de' => {
                'key' => 'Wert'
            }
        },
        "#{@dir}/en.yml" => {
            'en' => {
                'key' => 'value'
            }
        }
    }
    @store_mock.expect(:from_raw, nil, [data])
    App.new(@dir, store: @store_mock)
    @store_mock.verify
  end

  def test_persist_store
    return_data = {
        "#{@dir}/de.yml" => {
            'de' => {
                'key' => 'geänderter Wert'
            }
        },
        "#{@dir}/en.yml" => {
            'en' => {
                'key' => 'changed value'
            }
        }
    }
    @store_mock.expect(:from_raw, nil, [Hash])
    @store_mock.expect(:to_raw, return_data, [])
    app = App.new(@dir, store: @store_mock)
    app.persist_store
    @store_mock.verify

    assert_equal <<-YAML, File.read("#{@dir}/de.yml")
---
de:
  key: geänderter Wert
    YAML

    assert_equal <<-YAML, File.read("#{@dir}/en.yml")
---
en:
  key: changed value
    YAML

  end

  def teardown
    teardown_fixture_dir(@dir)
  end

end
