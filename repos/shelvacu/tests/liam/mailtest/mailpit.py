import argparse
import requests
import sys
import json


def info(msg: str):
    print(msg, file=sys.stderr)


def print_json(**kwargs):
    print(json.dumps(kwargs))


parser = argparse.ArgumentParser()
parser.add_argument(
    "--expect-mailpit-received",
    dest="expect",
    action="store_const",
    const="mailpit_received",
)
parser.add_argument(
    "--expect-mailpit-not-received",
    dest="expect",
    action="store_const",
    const="mailpit_not_received",
)
parser.add_argument("--mailpit-url")
parser.add_argument("--message-magic", type=str)

args = parser.parse_args()
msg_magic = args.message_magic
info(f"got args {args!r}")

mails = requests.get(args.mailpit_url + "/api/v1/messages").json()
found_message = False
for message_data in mails["messages"]:
    if msg_magic in message_data["Snippet"]:
        found_message = True
        break

print_json(found_message=found_message)
