#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p pyinfra

from pathlib import Path
from argparse import ArgumentParser

parser = ArgumentParser()
subparser = parser.add_subparsers()

class args():
    def __init__(self, *args, **kwargs):
        self.args = args
        self.kwargs = kwargs

def subcommand(*args, aliases=[]):
    def handler(fn):
        print(fn.__name__)
        current_parser = subparser.add_parser(fn.__name__, aliases=aliases)
        current_parser.set_defaults(fn=fn)
        for arg in args:
            current_parser.add_argument(*arg.args, **arg.kwargs)
    return handler


@subcommand(args('--name,-n', dest="name"))
def hello(name="world", **kwargs):
    print(f"hello, {name}")

if __name__ == "__main__":
    args = parser.parse_args()
    args_dict = args.__dict__
    print(args_dict)
    fn = args_dict.get('fn')
    if fn is not None:
        args_dict.pop('fn')
        fn(**args_dict)

