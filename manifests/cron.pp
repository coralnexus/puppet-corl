
define coral::cron (

  $resources = {},
  $overrides = {},
  $defaults  = {},
  $tag       = 'coral'

) {

  if ! empty($overrides) {
    $override_data = $overrides
  }
  else {
    $override_data = "${name}::cron"
  }

  if ! empty($defaults) {
    $default_data = $defaults
  }
  else {
    $default_data = "${name}::cron_defaults"
  }

  $data = flatten([ $resources, $override_data ])
  coral_resources('@cron', $data, $default_data, $tag)
  Cron<| tag == $tag |>
}
