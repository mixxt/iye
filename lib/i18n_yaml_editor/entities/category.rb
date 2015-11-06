require 'i18n_yaml_editor/entity'

module I18nYamlEditor
  class Category < Entity

    attributes :id, :complete

    def name
      id
    end

    def complete?
      complete
    end
  end
end
