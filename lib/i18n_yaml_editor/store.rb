module I18nYamlEditor
  class DuplicateTranslationError < StandardError; end

  class Store
    include Transformation

    attr_accessor :key_repository, :translation_repository, :locale_repository, :category_repository

    def initialize
      @category_repository = CategoryRepository.new(self)
      @key_repository = KeyRepository.new(self)
      @locale_repository = LocaleRepository.new(self)
      @translation_repository = TranslationRepository.new(self)
    end

    def locales
      locale_repository.all
    end

    def categories
      category_repository.all
    end

    def translations
      translation_repository.all
    end

    def key_complete?(key)
      keys = translation_repository.all_for_key(key)
      first_text_present = keys.first.text_present?
      keys.all?{ |k| k.text_present? == first_text_present }
    end

    def key_empty?(key)
      translation_repository.all_for_key(key).all?(&:text_blank?)
    end

    def filter_keys(filter)
      key_repository.filter_keys(filter)
    end

    def translations_for_key(key)
      translation_repository.all_for_key(key)
    end

    def path_templates
      key_repository.unique_path_templates
    end

    def from_raw(raw)
      raw.each do |path, data|
        flatten_hash(data).each do |full_key, text|
          add_raw_translation(full_key, text, path)
        end
      end
    end

    def add_raw_translation(full_key, value = nil, path = nil)
      _convert_raw_translation(full_key, value, path) do |translation|
        translation_repository.create(translation)
      end
    end

    def upsert_raw_translation(full_key, value = nil)
      _convert_raw_translation(full_key, value) do |translation|
        translation_repository.persist(translation)
      end
    end

    def to_raw
      locale_repository.all.each_with_object({}) do |locale, result|
        keys_by_path = key_repository.all.group_by(&:path_template)
        keys_by_path.each do |path, keys|
          data = keys.each_with_object({}) do |key, data|
            translation = translation_repository.find_by(locale_id: locale.id, key_id: key.id)
            data[key.id] = translation.value if translation
          end
          result[template_to_locale_path(path, locale.id)] = { locale.id => nest_hash(data) } unless data.empty?
        end
      end
    end

    private

    def _convert_raw_translation(full_key, value = nil, path = nil)
      raw_locale, raw_key = full_key.split('.', 2)

      locale = Locale.new(id: raw_locale)
      path_template = path ? locale_path_to_template(path, raw_locale) : nil
      key = Key.new(id: raw_key, path_template: path_template)
      translation = Translation.new(key_id: key.id, locale_id: locale.id, value: value)

      locale_repository.persist(locale) unless locale_repository.exists?(locale)
      key_repository.persist(key) unless key_repository.exists?(key)

      yield(translation)
    end

  end
end
