require "minitest/autorun"
require "capybara"
require "i18n_yaml_editor"

class Minitest::Test
  include I18nYamlEditor
end

module FixtureHelpers

  def setup_fixture_dir(subdir)
    Dir.mktmpdir("iye_fixture_#{subdir}").tap do |dir|
      FileUtils.cp Dir[I18nYamlEditor.root.join('test', 'fixtures', subdir, '*')], dir
    end
  end

  def teardown_fixture_dir(dir)
    FileUtils.remove_entry dir
  end

end

class CapybaraTest < Minitest::Test
  include Capybara::DSL
  include FixtureHelpers

  def setup
    @fixture_path = setup_fixture_dir('simple')
    @app = I18nYamlEditor::App.new(@fixture_path)
    Capybara.app = I18nYamlEditor::Web.app_stack(@app)
    Capybara.raise_server_errors = true
    Capybara.default_host = 'http://iye.test'
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
    teardown_fixture_dir(@fixture_path)
  end

  def store
    @app.store
  end
end