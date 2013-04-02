
define coral::firewall (

  $resources = {},
  $overrides = {},
  $defaults  = {},
  $tag       = 'coral'

) {

  if ! empty($overrides) {
    $override_data = $overrides
  }
  else {
    $override_data = "${name}::firewall"
  }

  if ! empty($defaults) {
    $default_data = $defaults
  }
  else {
    $default_data = "${name}::firewall_defaults"
  }

  $data = flatten([ $resources, $override_data ])
  coral_resources('@firewall', $data, $default_data, $tag)
  Firewall<| tag == $tag |>
}
