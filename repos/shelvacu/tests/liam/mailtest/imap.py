import imaplib
import imap_tools
import argparse
import sys
import ssl
import json
from typing import NamedTuple


def info(msg: str):
    print(msg, file=sys.stderr)


def mk_ctx():
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    return ctx


def print_json(**kwargs):
    print(json.dumps(kwargs))


def dig(obj, *keys):
    for key in keys:
        if isinstance(obj, dict):
            obj = obj.get(key)
        elif (isinstance(obj, list) or isinstance(obj, tuple)) and isinstance(key, int):
            if 0 <= key < len(obj):
                obj = obj[key]
            else:
                return None
        else:
            return None
        if obj is None:
            return None
    return obj


parser = argparse.ArgumentParser()
parser.add_argument("--host", type=str)
parser.add_argument("--insecure", default=False, action="store_true")
parser.add_argument("--move-to")
parser.add_argument("--dir", default=None)
parser.add_argument("--username")
parser.add_argument("--password")
parser.add_argument("--message-magic", type=str)

args = parser.parse_args()
msg_magic = args.message_magic

info(f"got args {args!r}")

username = args.username
password = args.password
if password is None:
    password = username

MessageInFolder = NamedTuple(
    "MessageInFolder", [("message", imap_tools.message.MailMessage), ("folder", str)]
)

info(f"looking for {msg_magic}")
result: bool
matching_messages = []
try:

    def connection() -> imap_tools.BaseMailBox:
        return imap_tools.MailBox(args.host, ssl_context=mk_ctx()).login(
            username, password
        )

    def find_messages(mailbox: imap_tools.BaseMailBox) -> list[MessageInFolder]:
        matching_messages = []
        directories = []
        for d in mailbox.folder.list():
            if "\\Noselect" not in d.flags:
                directories.append(d.name)
        # info(f"directories is {directories!r}")
        for imap_dir in directories:
            info(f"checking in {imap_dir!r}")
            mailbox.folder.set(imap_dir)
            # except imap_tools.errors.MailboxFolderSelectError as e:
            #     # info(f"failed to select folder {e!r}")
            #     continue
            for msg in mailbox.fetch(mark_seen=False):
                if "\\Deleted" in msg.flags:
                    continue
                # info(f"found message {msg.uid!r} with text {msg.text!r} in folder {imap_dir!r}")
                msg_str = msg.obj.as_string()
                info(f"flags: {msg.flags!r}")
                info(f"{msg_str}")
                if msg_magic == msg.text.strip():
                    in_folder = MessageInFolder(message=msg, folder=imap_dir)
                    matching_messages.append(in_folder)
        return matching_messages

    if args.move_to is not None:
        with connection() as mailbox:
            info("prefind")
            prefind = find_messages(mailbox)
            assert len(prefind) > 0, "Could not find message to move anywhere"
            assert len(prefind) == 1, "Found duplicate messages"
            mailbox.folder.set(prefind[0].folder)
            msg = prefind[0].message
            uid = msg.uid
            assert uid is not None
            info(f"about to move {uid} to {args.move_to}")
            res = mailbox.move(uid, args.move_to)
            info(f"{res=}")
            assert dig(res, 0, 0, 0, 0) is not None, f"failed to move"  # type: ignore
            info(f"done moving, res {res!r}")

    with connection() as mailbox:
        matching_messages = find_messages(mailbox)

except imaplib.IMAP4.error as e:
    info(f"IMAP error {e!r}")
    result = False
else:
    result = True


def mail_to_jsonish(m: MessageInFolder) -> dict:
    return {
        "folder": m.folder,
        "flags": m.message.flags,
        "body": m.message.text.strip(),
    }


print_json(
    result=result,
    messages=[mail_to_jsonish(m) for m in matching_messages],
)
