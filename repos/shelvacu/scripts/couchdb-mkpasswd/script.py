#!/usr/bin/env python3

# Based on https://sleeplessbeastie.eu/2020/03/13/how-to-generate-password-hash-for-couchdb-administrator/

# Generate password hash for CouchDB administrators

import argparse
import uuid
import hashlib
import os
import sys

# define and parse command-line options
parser = argparse.ArgumentParser(
    description="Generate password hash for CouchDB administrators"
)
parser.add_argument("--password", help="or env var PASSWORD (required)")
parser.add_argument(
    "--salt", default=uuid.uuid4().hex, help="Define salt (default: random)"
)
parser.add_argument(
    "--iterations",
    type=int,
    default=600000,
    help="Define number of iterations (default: %(default)s)",
)
parser.add_argument(
    "--verbose", action="store_true", help="Verbose mode (default: %(default)s)"
)
parser.add_argument(
    "--show-password",
    action="store_true",
    help="Show the password in plaintext (default: %(default)s)",
)
args = parser.parse_args()

password = ""

if args.password is not None:
    password = args.password

if password == "" and (password_env := os.environ.get("PASSWORD")) is not None:
    password = password_env

if password == "":
    print("ERROR: No password provided", file=sys.stderr)
    sys.exit(1)

# generate password hash
password_hash = hashlib.pbkdf2_hmac(
    "sha256", password.encode(), args.salt.encode(), args.iterations
)

# generate CouchDB hash
couchdb_hash = (
    "-pbkdf2:sha256-"
    + password_hash.hex()
    + ","
    + args.salt
    + ","
    + str(args.iterations)
)

if args.show_password:
    print("Password:", password)
# display detailed information in verbose mode
if args.verbose is True:
    if not args.show_password:
        print("-password not shown-")
    print("Salt:", args.salt)
    print("Iterations:", args.iterations)
    print("Hash:", password_hash.hex())

# display CouchDB hash
print("CouchDB hash:", couchdb_hash)
