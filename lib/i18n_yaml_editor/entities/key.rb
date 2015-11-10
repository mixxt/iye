require 'i18n_yaml_editor/entity'

module I18nYamlEditor
  class Key < Entity

    attributes :id, :path_template

    alias_method :name, :id

  end
end
