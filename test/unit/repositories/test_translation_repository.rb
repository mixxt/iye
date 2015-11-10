require 'test_helper'

class TestTranslationRepository < Minitest::Test
  def setup
    @store = Minitest::Mock.new
    @repository = TranslationRepository.new(@store)
  end

  def test_all_for_key
    @store.expect(:locales, [ Locale.new(id: 'de'), Locale.new(id: 'en') ])
    @repository.create Translation.new locale_id: 'de', key_id: 'hello', value: 'hallo'
    @repository.create Translation.new locale_id: 'en', key_id: 'hello', value: 'hello'
    @repository.create Translation.new locale_id: 'de', key_id: 'something', value: 'etwas'
    @repository.create Translation.new locale_id: 'en', key_id: 'something', value: 'something'

    entities = @repository.all_for_key Key.new(id: 'hello')
    assert_equal entities.map(&:id), %w{ de.hello en.hello }
    assert_equal entities.map(&:text), %w{ hallo hello }
  end

end
