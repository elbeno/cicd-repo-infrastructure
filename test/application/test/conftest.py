import pytest
from approvaltests.reporters.default_reporter_factory import set_default_reporter


def pytest_addoption(parser):
    parser.addoption("--pass", action="store_true", help="Test option", required=True)


@pytest.fixture(scope="session", autouse=True)
def set_default_reporter_for_all_tests() -> None:
    set_default_reporter(None)
