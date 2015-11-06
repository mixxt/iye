require 'i18n_yaml_editor/entity'

module I18nYamlEditor
  class Translation < Entity

    attributes :id, :text, :locale_id, :key_id

    def initialize(args)
      super(args.merge(id: args.values_at(:locale_id, :key_id).join('.')))

    end

    def text
      return nil unless stringish?

      String(self[:text]).strip.gsub(/\r\n/, "\n")
    end

    def stringish?
      self[:text].nil? || self[:text].is_a?(String)
    end

    def number_of_lines
      if text
        text.scan(/\n/).size + 1
      else
        1
      end
    end

    def complete?
      !!text
    end
  end
end
