#! /usr/bin/env nix-shell
#! nix-shell -p python3 -i python

from math import *

def b64d(data):
    from base64 import b64decode
    decoded = b64decode(data)
    return decoded.decode('utf-8')

def b64e(data):
    from base64 import b64encode
    raw = bytes(data, 'utf-8')
    encoded = b64encode(raw)
    return encoded.decode('utf-8')


def debug_mode():
    return getenv("DEBUG") != None

def eval_print(stmt, globals=globals(), locals=locals()):
    if debug_mode():
        print("Run statement: ", stmt)
    print(eval(stmt, globals, locals))

def getenv(key):
    from os import environ
    return environ.get(key)

def is_match(regex, text):
    from re import finditer
    m = list(finditer(regex, text))
    return len(m) != 0

def get_args():
    from sys import argv
    return argv[1:]

def eval_passed_stmt():
    args = get_args()
    if len(args) == 0:
        print("c4me [python expression]")
        return
    elif args[0] == "repl":
        repl()
    elif is_match(r"^[-0-9]", args[0]):
        eval_print(" ".join(args))
    elif is_match(r"^.*\(", args[0]):
        eval_print(" ".join(args))
    elif not is_match(r"^.*\(", args[0]):
        [fn, *args] = args
        eval_print("%s(*args)" %(fn), globals(), locals())
    elif len(args) == 1:
        eval_print(args[0])
def repl():
    import readline, rlcompleter
    from code import InteractiveConsole
    readline.parse_and_bind("tab: complete")
    InteractiveConsole(globals()).interact()

def main():
    eval_passed_stmt()
