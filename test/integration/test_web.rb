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
      page.fill_in('Key', with: 'key')
      page.click_button 'Apply Filter'
    end

    td = page.find('td.key')
    assert td
    assert_equal 'key', td.text
  end

  def test_root_filtering_by_text
    visit '/'
    within '.header' do
      page.fill_in('Text', with: 'Wert')
      page.click_button 'Apply Filter'
    end

    td = page.find('td.key')
    assert td
    assert_equal 'key', td.text
  end

  def test_root_empty_filter_result
    visit '/'
    within '.header' do
      page.fill_in('Key', with: 'unknown')
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

    page.fill_in 'translations[de.key][text]', with: 'geänderter Wert'
    page.fill_in 'translations[en.key][text]', with: 'changed value'
    page.click_button 'Save Translations'

    assert_equal 1, store.key_repository.count
    assert_equal 2, store.translation_repository.count
    assert_equal 'geänderter Wert', store.translation_repository.find('de.key').value
    assert_equal 'changed value', store.translation_repository.find('en.key').value

    assert_equal 'http://iye.test/?filters[key]=%5Ekey', current_url
  end

  def test_translation_json_update
    da_week = %w{ søndag mandag tirsdag onsdag torsdag fredag lørdag }
    en_week = %w{ sunday monday tuesday wednesday thursday friday saturday }

    store.add_raw_translation "da.day_names", da_week, "/tmp/da.yml"

    visit '/'
    click_link 'day_names'

    page.fill_in 'translations[en.day_names][value]', with: en_week.to_json
    page.click_button 'Save Translations'

    assert_equal da_week, store.translation_repository.find('da.day_names').value
    assert_equal en_week, store.translation_repository.find('en.day_names').value
  end

  def test_key_deletion
    visit '/'
    click_link 'key'
    within 'div.form-group' do
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
    within 'div.form-group' do
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
