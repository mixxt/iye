require 'yaml'

require 'i18n_yaml_editor'
require 'i18n_yaml_editor/web'
require 'i18n_yaml_editor/store'

module I18nYamlEditor
  class App
    attr_reader :base_path, :rel_path, :full_path
    attr_accessor :store

    def initialize(path, options = {})
      @base_path = Dir.pwd
      @rel_path = path
      @full_path = File.expand_path(path, @base_path)
      @store = options.fetch(:store){ Store.new }

      populate_store
    end

    def populate_store
      store.from_raw(load_files(Dir[full_path + '/**/*.yml']))
    end

    def persist_store
      save_files(store.to_raw)
    end

    def load_files(files)
      files.each_with_object({}) do |file, hash|
        hash[file] = YAML.load_file(file)
      end
    end

    def save_files(raw_data)
      raw_data.map do |file, data|
        File.open(file, 'w', encoding: 'utf-8') { |f| f << data.to_yaml(line_width: -1) }
      end
    end
  end
end
