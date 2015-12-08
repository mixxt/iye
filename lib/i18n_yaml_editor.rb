require 'pathname'
require 'json'

module I18nYamlEditor

  ##
  # Root path of gem
  #
  # @return [Pathname]
  def self.root
    @root ||= Pathname.new(File.expand_path('../..', __FILE__))
  end

  ##
  # Rack endpoint for given locale folder
  #
  # @param folder [String]
  # @return [Rack::Builder] rack app to be run
  def self.endpoint_for_folder(folder)
    I18nYamlEditor.endpoint_for_app(I18nYamlEditor::App.new(folder))
  end

  ##
  # Rack endpoint for given iye_app
  #
  # @param iye_app [I18nYamlEditor::App]
  # @return [Rack::Builder] rack app to be run
  def self.endpoint_for_app(app)
    Rack::Builder.new do
      run Web.new(app)
    end
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