require 'i18n_yaml_editor/repository'

module I18nYamlEditor
  class CategoryRepository < Repository

    def entity_class
      Category
    end

    def table
      @table ||= store.key_repository.all.each_with_object({}) do |key, hash|
        category_id = key.id.split('.').first
        hash[category_id] ||= begin
          category = Category.new(id: category_id)
          category.complete = store.key_complete?(key)
          category.attributes
        end
      end
    end

    def clear_cache
      @table = nil
    end

  end
end