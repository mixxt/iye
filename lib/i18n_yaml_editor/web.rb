require 'hobbit'
require 'rack'
require 'hobbit/render'
require 'tilt/erb'

require 'i18n_yaml_editor/app'

module I18nYamlEditor

  ##
  # Web interface to I18nYamlEditor::App
  class Web < Hobbit::Base
    include Hobbit::Render

    use Rack::Static, urls: ['/stylesheets', '/javascripts'], root: I18nYamlEditor.root.join('public')
    use Rack::MethodOverride

    extend Forwardable

    def initialize(iye_app)
      @iye_app = iye_app
    end

    ##
    # IYE app context
    #
    # @return [I18nYamlEditor::App]
    def app
      @iye_app
    end

    def views_path
      @views_path ||= I18nYamlEditor.root.join('views')
    end

    def default_layout
      "#{views_path}/layout.html.#{template_engine}"
    end

    ##
    # applications root path
    # can be different if it is mounted inside another rack app
    #
    # @return [String]
    def root_path(params = {})
      path = "#{request.script_name}/"
      path = "#{path}?#{Rack::Utils.build_nested_query(params)}" unless params.empty?
      path
    end

    def show_key_path(key)
      "#{root_path}?#{Rack::Utils.build_nested_query(filters: { key: "^#{key.id}" })}"
    end
    alias_method :show_category_path, :show_key_path

    def key_path(key)
      "#{root_path}keys?#{Rack::Utils.build_nested_query(key_id: key.id)}"
    end

    def edit_key_path(key)
      "#{root_path}keys/edit?#{Rack::Utils.build_nested_query(key_id: key.id)}"
    end

    def destroy_key_path(key)
      "#{root_path}keys/destroy?#{Rack::Utils.build_nested_query(key_id: key.id)}"
    end

    def_delegator :app, :store
    def_delegators :store, :category_repository, :key_repository, :locale_repository, :translation_repository

    ##
    # Helper method to access filters param
    #
    # @return [Hash]
    def filter_params
      request.params['filters'] || {}
    end

    get '/debug' do
      require 'json'

      response.headers['Content-Type'] = 'application/json; charset=utf-8'
      {
          locales: store.locales.map(&:inspect),
          categories: store.categories.map(&:inspect),
          keys: store.keys.map(&:inspect),
          translations: store.translations.map(&:inspect)
      }.to_json
    end

    # new
    get '/new' do
      render('new.html')
    end

    # create single key
    post '/create' do
      translations = request.params['translations']
      path_template = request.params['key']['path_template']

      translations.each do |key, translation|
        $message_key = Key.new(id: translation['key'], path_template: path_template)
        key_repository.create($message_key)

        translation['locales'].each do |locale_id, text|
          locale = locale_repository.find(locale_id)
          translation_repository.create Translation.new(locale_id: locale.id, key_id: $message_key.id, text: text)
        end
      end
      key_array = $message_key.attributes[:id].split('.')
      length = key_array.length - 1
      key_array.slice!(length)
      redirect_key = key_array.join

      app.persist_store
      response.redirect show_key_path(redirect_key)
    end

    # index
    get '/' do
      if filter_params.size > 0
        options = {}
        options[:key] = /#{filter_params['key']}/ if String(filter_params['key']).length > 0
        options[:text] = /#{filter_params['text']}/i if String(filter_params['text']).length > 0
        options[:complete] = false if filter_params['incomplete'] == 'on'
        options[:empty] = true if filter_params['empty'] == 'on'

        keys = store.filter_keys(options)

        render('translations.html', keys: keys)
      else
        render('categories.html', categories: store.categories)
      end
    end

    # mass update
    post '/update' do
      Array(request.params['translations']).each do |name, text_or_value|
        locale_id, key_id = name.split('.', 2)
        translation = Translation.new(locale_id: locale_id, key_id: key_id)
        if text_or_value['value']
          val = text_or_value['value']
          translation.value = val == 'null' ? nil : JSON.parse(val)
        else
          translation.text = text_or_value['text']
        end
        translation_repository.persist translation
      end

      app.persist_store

      response.redirect root_path(filters: filter_params)
    end

    # edit/rename key
    get '/keys/edit' do
      key = key_repository.find(request.params['key_id'])

      render('edit.html', key: key, translations: store.translations_for_key(key))
    end

    # confirm key deletion
    get '/keys/destroy' do
      key = key_repository.find(request.params['key_id'])

      render('destroy.html', key: key, translations: store.translations_for_key(key))
    end

    # update key
    put '/keys' do
      key = key_repository.find(request.params['key_id'])
      key_params = request.params.fetch('key')


      store.rename_key(key, key_params['new_id']) if key_params['new_id']
      app.persist_store

      response.redirect(show_key_path(key))
    end

    # delete key
    delete '/keys' do
      key = key_repository.find(request.params['key_id'])

      store.delete_key(key)
      app.persist_store

      response.redirect(root_path)
    end
  end
end
