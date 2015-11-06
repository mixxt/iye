require 'i18n_yaml_editor/repository'

module I18nYamlEditor
  class LocaleRepository < Repository

    def entity_class
      Locale
    end

  end
end