# as if by already including boost
add_library(boost_mp11 INTERFACE)
add_versioned_package(URI "gh:boostorg/mp11#boost-1.83.0" TARGET "boost_mp11")

# check recipe idempotence
fmt_recipe("11.1.4")
boost_sml_recipe("v1.1.11")
boost_hana_recipe("boost-1.83.0")
