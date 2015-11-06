module I18nYamlEditor
  class TransformationError < StandardError; end

  module Transformation
    LOCALE_PLACEHOLDER = '%LOCALE%'

    def flatten_hash hash, namespace=[], tree={}
      hash.each {|key, value|
        child_ns = namespace.dup << key
        if value.is_a?(Hash)
          flatten_hash value, child_ns, tree
        else
          tree[child_ns.join('.')] = value
        end
      }
      tree
    end
    module_function :flatten_hash

    def nest_hash hash
      result = {}
      hash.each {|key, value|
        begin
          sub_result = result
          keys = key.split(".")
          keys.each_with_index {|k, idx|
            if keys.size - 1 == idx
              sub_result[k.to_s] = value
            else
              sub_result = (sub_result[k.to_s] ||= {})
            end
          }
        rescue => e
          raise TransformationError.new("Failed to nest key: #{key.inspect} with value: #{value.inspect}")
        end
      }
      result
    end
    module_function :nest_hash

    def sub_locale_in_path(path, from_locale, to_locale)
      path
          .sub(/(\/|\.)#{from_locale}\.yml$/, "\\1#{to_locale}.yml")
          .sub(/\/#{from_locale}([^\/]+)\.yml$/, "/#{to_locale}\\1.yml")
    end
    module_function :sub_locale_in_path

    def locale_path_to_template(path, locale)
      raise "Locale #{locale.inspect} not found in path #{path} when trying to strip it" unless path.include?(locale)

      sub_locale_in_path(path, locale, LOCALE_PLACEHOLDER)
    end
    module_function :locale_path_to_template

    def template_to_locale_path(path, locale)
      raise "Locale placeholder not found in path #{path} when trying to add locale #{locale.inspect}" unless path.include?(LOCALE_PLACEHOLDER)

      sub_locale_in_path(path, LOCALE_PLACEHOLDER, locale)
    end
    module_function :template_to_locale_path
  end
end
