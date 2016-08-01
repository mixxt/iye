require 'i18n_yaml_editor/entity'

module I18nYamlEditor
  class Translation < Entity

    attributes :id, :value, :locale_id, :key_id

    alias_method :name, :id

    def locale_id=(locale_id)
      super.tap{ update_id }
    end
    def key_id=(key_id)
      super.tap{ update_id }
    end

    def text
      String(value)
    end

    def text=(text)
      self.value = text_to_value(text)
    end

    def stringish?
      value.nil? || value.is_a?(String)
    end
    def not_stringish?
      !stringish?
    end

    def number_of_lines
      if text
        plain_size = text.scan(/\n/).size + 1
        size = plain_size > 10 ? 10 : plain_size
      else
        size = 1
      end
      size
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

    private

    def text_to_value(text)
      if String(text).empty?
        nil
      else
        text.strip.gsub(/\r\n/, "\n")
      end
    end

    def update_id
      self.id = attributes.values_at(:locale_id, :key_id).join('.')
    end

  end
end
