import smtplib
import argparse
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


parser = argparse.ArgumentParser()
parser.add_argument("--host", type=str)
parser.add_argument("--mailfrom", default="foo@example.com")
parser.add_argument("--rcptto", default="awesome@vacu.store")
parser.add_argument("--subject", default="Some test message")
parser.add_argument("--header", action="append", default=[])
parser.add_argument("--submission", default=False, action="store_true")
parser.add_argument("--smtp-starttls", default=None, action="store_true")
parser.add_argument("--username")
parser.add_argument("--password")
parser.add_argument("--message-magic", type=str)

args = parser.parse_args()

info(f"got args {args!r}")

args.header.append(f"Subject: {args.subject}")


username = args.username
password = args.password
if password is None:
    password = username

result = ""

try:
    smtp = None
    if args.submission:
        smtp = smtplib.SMTP_SSL(args.host, port=465, context=mk_ctx())
    else:
        smtp = smtplib.SMTP(args.host, port=25)
    smtp.ehlo()
    if args.smtp_starttls:
        smtp.starttls(context=mk_ctx())
        smtp.ehlo()
    if args.submission:
        smtp.login(username, password)
    headers = "\n".join(args.header)
    smtp.sendmail(args.mailfrom, args.rcptto, f"{headers}\n\n{args.message_magic}")
    smtp.close()
except smtplib.SMTPRecipientsRefused:
    result = False
except smtplib.SMTPSenderRefused:
    result = False
else:
    result = True

print_json(result=result)
