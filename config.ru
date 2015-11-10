require 'i18n_yaml_editor'

# mounted on path as (rails)-integration example and for testing
map('/dev/iye') {
  run I18nYamlEditor.endpoint_for_folder('example')
}
