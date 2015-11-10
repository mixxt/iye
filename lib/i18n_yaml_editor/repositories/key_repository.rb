require 'i18n_yaml_editor/repository'

module I18nYamlEditor
  class KeyRepository < Repository

    def entity_class
      Key
    end

    def _persisting(key)
      store.category_repository.clear_cache
      yield
    end

    def filter_keys(filter)
      filters = []

      filters << ->(key){ key.id =~ filter[:key] } if filter[:key]
      filters << ->(key){ store.key_complete?(key) == filter[:complete] } if filter.key?(:complete)
      filters << ->(key){ store.key_empty?(key) == filter[:empty] } if filter.key?(:empty)
      filters << ->(key) do
        store.translations_for_key(key).any?{ |t| t.text =~ filter[:text] }
      end if filter[:text]

      all.select do |key|
        filters.all?{ |f| f.call(key) }
      end
    end

  end
end