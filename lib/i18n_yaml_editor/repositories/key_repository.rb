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

    def filter(filter)
      filters = []
      filters << ->(key){ key.id =~ filter[:key] } if filter[:key]

      all.select do |key|
        filters.all?{ |f| f.call(key) }
      end
    end

  end
end