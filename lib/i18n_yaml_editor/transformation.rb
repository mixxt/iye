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
      hash.keys.sort.each {|key|
        value = hash[key]
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

    ##
    # Replaces from_locale with to_locale in filename of path
    # Supports filenames with locale prefix or suffix
    #
    # @param [String] path
    # @param [String] from_locale
    # @param [String] to_locale
    #
    # @example Get path for en locale path from existing dk locale path
    #   Transformation.replace_locale_in_path('dk', 'en', '/tmp/dk.foo.yml') #=> "/tmp/en.foo.yml"
    #   Transformation.replace_locale_in_path('dk', 'en', '/tmp/foo.dk.yml') #=> "/tmp/foo.en.yml"
    #
    # @return [String]
    def replace_locale_in_path(path, from_locale, to_locale)
      parts = File.basename(path).split('.')
      parts[parts.index(from_locale)] = to_locale
      File.join(File.dirname(path), parts.join('.'))
    end
    module_function :replace_locale_in_path

    def locale_path_to_template(path, locale)
      raise "Locale #{locale.inspect} not found in path #{path} when trying to strip it" unless path.include?(locale)

      replace_locale_in_path(path, locale, LOCALE_PLACEHOLDER)
    end
    module_function :locale_path_to_template

    def template_to_locale_path(path, locale)
      raise "Locale placeholder not found in path #{path} when trying to add locale #{locale.inspect}" unless path.include?(LOCALE_PLACEHOLDER)

      replace_locale_in_path(path, LOCALE_PLACEHOLDER, locale)
    end
    module_function :template_to_locale_path
  end
end
