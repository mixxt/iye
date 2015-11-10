require 'i18n_yaml_editor/entity'

module I18nYamlEditor
  class Category < Entity

    attributes :id, :complete

    alias_method :name, :id

    def complete?
      complete
    end
  end
end
