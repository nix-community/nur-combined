import greenlet


def hello() -> str:
    return greenlet.greenlet(lambda: "hello from greenlet").switch()


def main() -> None:
    print(hello())
