require 'i18n_yaml_editor/repository'

module I18nYamlEditor
  class TranslationRepository < Repository

    def entity_class
      Translation
    end

    def all_for_key(key)
      store.locales.map do |locale|
        find_or_initialize_by(locale_id: locale.id, key_id: key.id)
      end
    end

    def find_by(attributes)
      if attributes.key?(:locale_id) && attributes.key?(:key_id)
        id = attributes.values_at(:locale_id, :key_id).join('.')
        data = table[id]
        to_entity(data) if data
      else
        super
      end
    end

  end
end