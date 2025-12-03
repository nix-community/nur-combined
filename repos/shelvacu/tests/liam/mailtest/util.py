import sys
import ssl
import json


def info(msg: str):
    print(msg, file=sys.stderr)


def mk_ctx():
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    return ctx


def print_json(**kwargs):
    print(json.dumps(kwargs))
