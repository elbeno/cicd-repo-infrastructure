#include <catch2/catch_template_test_macros.hpp>
#include <catch2/catch_test_macros.hpp>
#include <rapidcheck/catch.h>

TEST_CASE("catch2 test", "[test]") {}

TEMPLATE_TEST_CASE("catch2 template test", "[test]", int) {}

TEST_CASE("catch2 with rapidcheck", "[test]") {
    rc::prop("test property", [](unsigned int a) { return a * 2u == a + a; });
}
