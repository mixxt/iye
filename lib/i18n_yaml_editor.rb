require 'pathname'

module I18nYamlEditor

  ##
  # Root path of gem
  #
  # @return [Pathname]
  def self.root
    @root ||= Pathname.new(File.expand_path('../..', __FILE__))
  end

end

require 'i18n_yaml_editor/entities/category'
require 'i18n_yaml_editor/entities/key'
require 'i18n_yaml_editor/entities/locale'
require 'i18n_yaml_editor/entities/translation'
require 'i18n_yaml_editor/repositories/category_repository'
require 'i18n_yaml_editor/repositories/key_repository'
require 'i18n_yaml_editor/repositories/locale_repository'
require 'i18n_yaml_editor/repositories/translation_repository'
require 'i18n_yaml_editor/transformation'
require 'i18n_yaml_editor/app'
require 'i18n_yaml_editor/store'
require 'i18n_yaml_editor/web'