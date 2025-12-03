import os
import sys
import json
import argparse
from pathlib import Path

DATA_PATH = Path("@dataFn@")
DATA = json.loads(DATA_PATH.read_text())

SOPS_BIN = DATA["sopsBin"]

EMPTY_CONST = object()


class EnumAction(argparse._StoreConstAction):
    def __init__(
        self,
        option_strings,
        dest,
        const=EMPTY_CONST,
        default=False,
        required=False,
        help=None,
    ):
        if const is EMPTY_CONST:
            # copying logic in _get_optional_kwargs
            long_option_strings = []
            for option_string in option_strings:
                # strings starting with two prefix characters are long options
                if len(option_string) > 1 and option_string[1] in "-":
                    long_option_strings.append(option_string)

            if long_option_strings:
                const_option_string = long_option_strings[0]
            else:
                const_option_string = option_strings[0]
            const = const_option_string.lstrip("-")
            const = const.replace("-", "_")
        super(EnumAction, self).__init__(
            option_strings=option_strings,
            dest=dest,
            const=const,
            required=required,
            help=help,
            default=default,
        )


parser = argparse.ArgumentParser(
    prog="Shel Wifi Manager",
)

parser.add_argument("--add", action=EnumAction, dest="action")
parser.add_argument("--edit", action=EnumAction, dest="action")
parser.add_argument("ssid")

args = parser.parse_args()


def die(msg: str):
    sys.stderr.write(msg + "\n")
    sys.exit(1)


if args.action is None:
    die("specify an action")

wifi_data = "TODO"
