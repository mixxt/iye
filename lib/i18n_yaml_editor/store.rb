module I18nYamlEditor
  class DuplicateTranslationError < StandardError; end

  class Store
    include Transformation
    extend Forwardable

    attr_accessor :key_repository, :translation_repository, :locale_repository, :category_repository

    def_delegator :category_repository, :all, :categories
    def_delegator :key_repository, :all, :keys
    def_delegator :locale_repository, :all, :locales
    def_delegator :translation_repository, :all, :translations

    def_delegator :key_repository, :filter_keys
    def_delegator :key_repository, :unique_path_templates, :path_templates
    def_delegator :translation_repository, :all_for_key, :translations_for_key

    def initialize
      @category_repository = CategoryRepository.new(self)
      @key_repository = KeyRepository.new(self)
      @locale_repository = LocaleRepository.new(self)
      @translation_repository = TranslationRepository.new(self)
    end

    def key_complete?(key)
      translations = translation_repository.all_for_key(key)
      first_text_present = translations.first.text_present?
      translations.all?{ |k| k.text_present? == first_text_present }
    end

    def key_empty?(key)
      translation_repository.all_for_key(key).all?(&:text_blank?)
    end

    ##
    # Renames given key to new_id, migrates translations and persists it
    def rename_key(key, new_id)
      translations = translation_repository.all_for_key(key)
      delete_key(key)

      key.id = new_id
      translations.each{ |t| t.key_id = new_id }

      key_repository.create key
      translations.each{ |t| translation_repository.create t }

      key
    end

    def delete_key(key)
      translations_for_key(key).each do |translation|
        translation_repository.delete(translation)
      end
      key_repository.delete(key)
    end

    def from_raw(raw)
      raw.each do |path, data|
        flatten_hash(data).each do |full_key, text|
          add_raw_translation(full_key, text, path)
        end
      end
    end

    def add_raw_translation(full_key, value = nil, path = nil)
      translation = _convert_raw_translation(full_key, value, path)
      translation_repository.create(translation)
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

      translation
    end

  end
end
