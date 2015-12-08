require 'test_helper'

class TestWeb < CapybaraTest

  def test_root_links_keys
    visit '/'
    link = page.find_link('key')
    assert link
    assert_equal '/?filters[key]=%5Ekey', link['href']
  end

  def test_root_links_new
    visit '/'
    link = page.find_link('New Translation')
    assert link
    assert_equal '/new?key=', link['href']
  end

  def test_root_filtering_by_key
    visit '/'
    within '.header' do
      page.fill_in('Key:', with: 'key')
      page.click_button 'Apply Filter'
    end

    td = page.find('td.key')
    assert td
    assert_equal 'key', td.text
  end

  def test_root_filtering_by_text
    visit '/'
    within '.header' do
      page.fill_in('Text:', with: 'Wert')
      page.click_button 'Apply Filter'
    end

    td = page.find('td.key')
    assert td
    assert_equal 'key', td.text
  end

  def test_root_empty_filter_result
    visit '/'
    within '.header' do
      page.fill_in('Key:', with: 'unknown')
      page.click_button 'Apply Filter'
    end

    assert page.has_text?('Could not find any keys for your search.')
    link = page.find_link('Create a new one')
    assert link
    assert_equal '/new?key=unknown', link['href']
  end

  def test_translation_update
    visit '/'
    click_link 'key'

    page.fill_in 'translations[de.key]', with: 'geänderter Wert'
    page.fill_in 'translations[en.key]', with: 'changed value'
    page.click_button 'Save Translations'

    assert_equal 1, store.key_repository.count
    assert_equal 2, store.translation_repository.count
    assert_equal 'geänderter Wert', store.translation_repository.find('de.key').value
    assert_equal 'changed value', store.translation_repository.find('en.key').value

    assert_equal 'http://iye.test/?filters[key]=%5Ekey', current_url
  end

  def test_key_and_translation_creation
    visit '/'
    click_link 'New Translation'

    page.select "#{@fixture_path}/%LOCALE%.yml", from: 'key[path_template]'
    page.fill_in 'key[id]', with: 'namespace.new_key'
    page.fill_in 'key[translations][de]', with: 'neuer Wert'
    page.fill_in 'key[translations][en]', with: 'new value'
    page.click_button 'Create key'

    assert_equal 2, store.key_repository.count
    assert_equal 4, store.translation_repository.count
    assert_equal "#{@fixture_path}/%LOCALE%.yml", store.key_repository.find('namespace.new_key').path_template
    assert_equal 'neuer Wert', store.translation_repository.find('de.namespace.new_key').value
    assert_equal 'new value', store.translation_repository.find('en.namespace.new_key').value

    assert_equal 'http://iye.test/?filters[key]=%5Enamespace.new_key', current_url
  end

  def test_key_deletion
    visit '/'
    click_link 'key'
    within 'tr.translation' do
      click_link 'Delete'
    end
    assert_equal 'http://iye.test/keys/destroy?key_id=key', current_url

    click_button 'Yes, really delete'

    assert_equal 0, store.key_repository.count
    assert_equal 0, store.translation_repository.count

    assert_equal '/', current_path
  end

  def test_key_renaming
    rename_calls = []
    store.define_singleton_method(:rename_key) { |key, name| rename_calls << [ key, name ]; key.id = name; key }

    visit '/'
    click_link 'key'
    within 'tr.translation' do
      click_link 'Rename'
    end
    assert_equal 'http://iye.test/keys/edit?key_id=key', current_url

    page.fill_in 'key[new_id]', with: 'renamed_key'
    page.click_button 'Update key'

    assert_equal rename_calls.count, 1
    assert_equal rename_calls.first[0].class, Key
    assert_equal rename_calls.first[1], 'renamed_key'

    assert_equal 'http://iye.test/?filters[key]=%5Erenamed_key', current_url
  end

end
