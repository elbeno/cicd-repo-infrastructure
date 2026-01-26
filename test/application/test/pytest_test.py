from hypothesis import given, strategies as st

small_ints = st.integers(min_value=0, max_value=1000)

import sys



@given(small_ints, small_ints)
def test_addition_is_commutative(a: int, b: int):
    assert False, f"python is {sys.executable}"
    assert a + b == b + a
