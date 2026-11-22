from fixture import hello


def test_hello() -> None:
    assert hello() == "hello from greenlet"
