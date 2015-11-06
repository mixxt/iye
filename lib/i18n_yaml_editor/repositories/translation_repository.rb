require 'i18n_yaml_editor/repository'

module I18nYamlEditor
  class TranslationRepository < Repository

    def entity_class
      Translation
    end

    def all_for_key(key)
      # TODO add index for performance
      all.select{ |translation| translation.key_id == key.id }
    end

  end
end