
define corl::nagios_servicegroup (

  $resources = {},
  $overrides = {},
  $defaults  = {},
  $options   = {}

) {
  $data = flatten([ $resources, $overrides ])
  corl_resources('@nagios_servicegroup', $data, $defaults, $name, $options)
  Nagios_servicegroup<| tag == $name |>
}
