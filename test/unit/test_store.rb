# encoding: utf-8

require "test_helper"
require "i18n_yaml_editor/store"

class TestStore < Minitest::Test
  def setup
    @store = Store.new
  end

  def test_add_raw_translations
    translation = Translation.new(locale_id: 'da', key_id: 'session.login')

    @store.add_raw_translation(translation.id, nil, nil)

    assert_equal 1, @store.translation_repository.count
    stored_translation = @store.translation_repository.find('da.session.login')
    assert stored_translation
    assert_equal translation.locale_id, stored_translation.locale_id
    assert_equal translation.key_id, stored_translation.key_id
    assert_equal translation.name, stored_translation.name
    assert_equal translation.text, stored_translation.text

    assert_equal 1, @store.key_repository.count
    assert_equal 'session.login', @store.key_repository.first.name

    assert_equal 1, @store.category_repository.count
    assert_equal 'session', @store.category_repository.first.name

    assert_equal 1, @store.locale_repository.count
    assert_equal 'da', @store.locale_repository.first.id
  end

  def test_complete_with_text_for_all_translations
    key = Key.new(id: 'session.login')
    @store.add_raw_translation "da.session.login", "Log ind"
    @store.add_raw_translation "en.session.login", "Sign in"

    assert @store.key_complete?(key)
  end

  def test_complete_with_no_texts
    key = Key.new(id: 'session.login')
    @store.add_raw_translation "da.session.login"
    @store.add_raw_translation "en.session.login"

    assert @store.key_complete?(key)
  end

  def test_not_complete_with_missing_texts
    key = Key.new(id: 'session.login')
    @store.add_raw_translation "da.session.login", "Log ind"
    @store.add_raw_translation "en.session.login"

    assert_equal false, @store.key_complete?(key)
  end

  def test_empty_with_no_texts
    key = Key.new(id: 'session.login')
    @store.add_raw_translation "da.session.login"
    @store.add_raw_translation "en.session.login"

    assert @store.key_empty?(key)
  end

  def test_empty_with_some_texts
    key = Key.new(id: 'session.login')
    @store.add_raw_translation "da.session.login", "Log ind"
    @store.add_raw_translation "en.session.login"

    assert_equal false, @store.key_empty?(key)
  end

  # def test_add_duplicate_translation
  #   t1 = Translation.new(:name => "da.session.login")
  #   t2 = Translation.new(:name => "da.session.login")
  #   @store.add_raw_translation(t1)
  #
  #   assert_raises(DuplicateTranslationError) {
  #     @store.add_raw_translation(t2)
  #   }
  # end

  def test_filter_keys_on_key
    @store.add_raw_translation("da.session.login")
    @store.add_raw_translation("da.session.logout")

    result = @store.filter_keys(key: /login/)

    assert_equal 1, result.size
    assert_equal %w(session.login), result.map(&:name)
  end

  def test_filter_keys_on_complete
    @store.add_raw_translation "da.session.login", "Log ind"
    @store.add_raw_translation "en.session.login"
    @store.add_raw_translation "da.session.logout", "Log ud"
    @store.add_raw_translation "en.session.logout", "Logout"

    result = @store.filter_keys(complete: false)

    assert_equal %w(session.login), result.map(&:name)
  end

  def test_filter_keys_on_empty
    @store.add_raw_translation "da.session.login", "Log ind"
    @store.add_raw_translation "da.session.logout"

    result = @store.filter_keys(empty: true)

    assert_equal %w(session.logout), result.map(&:name)
  end

  def test_filter_keys_on_text
    @store.add_raw_translation "da.session.login", "Log ind"
    @store.add_raw_translation "da.session.logout", "Log ud"
    @store.add_raw_translation "da.app.name", "Translator"

    result = @store.filter_keys(text: /Log/)

    assert_equal 2, result.size
    assert_equal %w(session.login session.logout).sort, result.map(&:name)
  end

  def test_from_raw
    input = {
        '/tmp/session.da.yml' => {
            da: {
                session: { login: "Log ind" }
            }
        }
    }
    store = Store.new

    store.from_raw(input)

    assert_equal 1, store.translations.size
    translation = store.translations.first
    assert_equal "da", translation.locale_id
    assert_equal "session.login", translation.key_id
    assert_equal "Log ind", translation.text
  end

  def test_to_raw
    expected = {
      "/tmp/session.da.yml" => {
        "da" => {
          "session" => {
            "login" => "Log ind",
            "logout" => "Log ud"
          }
        }
      },
      "/tmp/session.en.yml" => {
        "en" => {
          "session" => {
            "login" => "Sign in"
          }
        }
      },
      "/tmp/da.yml" => {
        "da" => {
          "app_name" => "Oversætter",
          "empty_string" => "",
          "nil_string" => nil,
          "day_names" => [ 'søndag', 'mandag', 'tirsdag', 'onsdag', 'torsdag', 'fredag', 'lørdag' ]
        }
      }
    }

    store = Store.new
    store.add_raw_translation "da.session.login", "Log ind", "/tmp/session.da.yml"
    store.add_raw_translation "en.session.login", "Sign in", "/tmp/session.en.yml"
    store.add_raw_translation "da.session.logout", "Log ud", "/tmp/session.da.yml"
    store.add_raw_translation "da.app_name", "Oversætter", "/tmp/da.yml"
    store.add_raw_translation "da.empty_string", "", "/tmp/da.yml"
    store.add_raw_translation "da.nil_string", nil, "/tmp/da.yml"
    store.add_raw_translation "da.day_names", [ 'søndag', 'mandag', 'tirsdag', 'onsdag', 'torsdag', 'fredag', 'lørdag' ], "/tmp/da.yml"

    assert_equal expected, store.to_raw
  end
end
