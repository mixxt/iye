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

    use Rack::Static, urls: ['/stylesheets'], root: I18nYamlEditor.root.join('public')
    use Rack::MethodOverride

    extend Forwardable

    ##
    # Rack app stack with endpoints for given iye_app
    #
    # @param iye_app [I18nYamlEditor::App]
    # @return [Rack::Builder] rack app to be run
    def self.app_stack(iye_app)
      Rack::Builder.new do
        use AppEnv, iye_app
        run Web
      end
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

    ##
    # IYE app context
    #
    # @return [I18nYamlEditor::App]
    def app
      env['iye.app'] || raise('Request outside of iye app context; please use I18nYamlEditor#app_stack(iye_app)')
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
      key_params = request.params['key']
      translation_params = key_params.delete('translations')

      key = Key.new(id: key_params.fetch('id'), path_template: key_params.fetch('path_template'))
      key_repository.create(key)

      translation_params.each do |locale_id, text|
        text = nil if text.empty?
        locale = locale_repository.find(locale_id)
        translation_repository.persist Translation.new(locale_id: locale.id, key_id: key.id, value: text)
      end

      app.persist_store

      response.redirect show_key_path(key)
    end

    # index
    get '/' do
      if (filters = request.params['filters'])
        options = {}
        options[:key] = /#{filters['key']}/ if String(filters['key']).length > 0
        options[:text] = /#{filters['text']}/i if String(filters['text']).length > 0
        options[:complete] = false if filters['incomplete'] == 'on'
        options[:empty] = true if filters['empty'] == 'on'

        keys = store.filter_keys(options)

        render('translations.html', keys: keys)
      else
        render('categories.html', categories: store.categories)
      end
    end

    # mass update
    post '/update' do
      if (translations = request.params['translations'])
        translations.each do |name, text|
          text = nil if text.empty?
          store.upsert_raw_translation name, text
        end
        app.persist_store
      end

      response.redirect root_path(filters: filter_params)
    end

    # confirm key deletion
    get '/keys/:id/destroy' do
      key = key_repository.find(request.params[:id])

      render('destroy.html', key: key, translations: store.translations_for_key(key))
    end

    # delete key
    delete '/keys/:id' do
      key = key_repository.find(request.params[:id])

      store.translations_for_key(key).each do |translation|
        translation_repository.delete(translation)
      end
      key_repository.delete(key)

      response.redirect(root_path)
    end

    ##
    # Middleware that sets iye_app in request environment
    # Used by I18nYamlEditor::Web#app_stack
    class AppEnv
      def initialize(app, iye_app)
        @app = app
        @iye_app = iye_app
      end

      def call(env)
        env['iye.app'] = @iye_app

        @app.call(env)
      end
    end
  end
end
