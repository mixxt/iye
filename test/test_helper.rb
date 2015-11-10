require "minitest/autorun"
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