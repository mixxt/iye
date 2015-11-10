require 'i18n_yaml_editor/entity'

module I18nYamlEditor
  class Locale < Entity

    attributes :id

    alias_method :name, :id

  end
end
