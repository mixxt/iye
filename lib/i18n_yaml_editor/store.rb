require 'set'
require 'pathname'

module I18nYamlEditor
  class DuplicateTranslationError < StandardError; end

  class Store
    include Transformation

    attr_accessor :key_repository, :translation_repository, :locale_repository, :category_repository

    def initialize
      @locale_repository = LocaleRepository.new(self)
      @category_repository = CategoryRepository.new(self)
      @key_repository = KeyRepository.new(self)
      @translation_repository = TranslationRepository.new(self)
    end

    def key_complete?(key)
      translation_repository.all_for_key(key).all?(&:complete?)
    end

    def key_empty?(key)
      # TODO
    end

    def from_yaml(yaml, path)
      flatten_hash(yaml).each do |full_key, text|
        raw_locale, raw_key = full_key.split('.', 2)

        locale = Locale.new(id: raw_locale)
        key = Key.new(id: raw_key, path_template: locale_path_to_template(path, raw_locale))
        translation = Translation.new(key_id: key.id, locale_id: locale.id, text: text)

        locale_repository.persist(locale) unless locale_repository.exists?(locale)
        key_repository.persist(key) unless key_repository.exists?(key)
        translation_repository.create(translation)
      end
    end

    def to_yaml
      result = {}
      files = self.translations.values.group_by(&:file)
      files.each {|file, translations|
        file_result = {}
        translations.each {|translation|
          file_result[translation.name] = translation.text
        }
        result[file] = nest_hash(file_result)
      }
      result
    end
  end
end
