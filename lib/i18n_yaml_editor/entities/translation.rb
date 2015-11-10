require 'i18n_yaml_editor/entity'

module I18nYamlEditor
  class Translation < Entity

    attributes :id, :value, :locale_id, :key_id

    alias_method :name, :id

    def initialize(args)
      super(args.merge(id: args.values_at(:locale_id, :key_id).join('.')))
    end

    def text
      return nil unless stringish?

      String(self[:value]).strip.gsub(/\r\n/, "\n")
    end

    def stringish?
      self[:value].nil? || self[:value].is_a?(String)
    end

    def number_of_lines
      if text
        text.scan(/\n/).size + 1
      else
        1
      end
    end

    def text_present?
      !!text && text.length > 0
    end
    def text_blank?
      !text_present?
    end

    def full_key
      [locale_id, key_id].join('.')
    end
  end
end
