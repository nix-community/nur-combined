"""Contacts for the phone's Directories button, and caller-ID names for asterisk.

Contacts are read from CONTACTS_FILE on every request, one per line:

    +15555550123 Alice Smith
    5555550124   Bob (work)

Blank lines and lines starting with # are ignored.
"""

import os
import re
from math import ceil

from flask import Blueprint, Response, request
from lxml import etree
from lxml.builder import E as tag

CONTACTS_FILE = os.environ.get("CONTACTS_FILE", "contacts.txt")

# The most DirectoryEntry elements a CiscoIPPhoneDirectory may hold.
PAGE_SIZE = 32

blueprint = Blueprint("contacts", __name__)


def normalise(number):
    """E.164 for anything that looks North American or international."""
    number = number.strip()
    digits = re.sub(r"[^0-9]", "", number)

    if number.startswith("+"):
        return "+" + digits
    if digits.startswith("011"):
        return "+" + digits[3:]
    if len(digits) == 10:
        return "+1" + digits
    if len(digits) == 11 and digits.startswith("1"):
        return "+" + digits
    return digits


def load():
    try:
        with open(CONTACTS_FILE, encoding="UTF-8") as file:
            lines = file.read().splitlines()
    except FileNotFoundError:
        return []

    contacts = []
    for line in lines:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        number, *name = line.split(None, 1)
        contacts.append((name[0] if name else number, normalise(number)))

    contacts.sort(key=lambda contact: contact[0].casefold())
    return contacts


def xml_response(document):
    xml = etree.tostring(
        document, xml_declaration=True, encoding="UTF-8", pretty_print=True
    )
    return (
        Response(
            xml,
            headers={
                "Content-Type": "text/xml",
                "Expires": "Thu, 01 Jan 1970 00:00:00 GMT",
            },
        ),
        200,
    )


@blueprint.route("/directory")
def directory():
    contacts = load()
    pages = max(1, ceil(len(contacts) / PAGE_SIZE))

    try:
        page = int(request.args.get("page", "1"))
        if page < 1 or page > pages:
            raise ValueError
    except ValueError:
        page = 1

    title = "Contacts" + (" " + str(page) + "/" + str(pages) if pages > 1 else "")
    document = tag("CiscoIPPhoneDirectory", tag("Title", title))

    for name, number in contacts[(page - 1) * PAGE_SIZE : page * PAGE_SIZE]:
        document.append(
            tag("DirectoryEntry", tag("Name", name), tag("Telephone", number))
        )

    position = iter(map(str, range(1, 5)))
    document.extend(
        [
            tag(
                "SoftKeyItem",
                tag("Name", "Exit"),
                tag("URL", "Init:Directories"),
                tag("Position", next(position)),
            ),
            tag(
                "SoftKeyItem",
                tag("Name", "Call"),
                tag("URL", "SoftKey:Select"),
                tag("Position", next(position)),
            ),
        ]
    )

    if page < pages:
        document.append(
            tag(
                "SoftKeyItem",
                tag("Name", "Next"),
                tag("URL", request.base_url + "?page=" + str(page + 1)),
                tag("Position", next(position)),
            )
        )

    if page > 1:
        document.append(
            tag(
                "SoftKeyItem",
                tag("Name", "Previous"),
                tag("URL", request.base_url + "?page=" + str(page - 1)),
                tag("Position", next(position)),
            )
        )

    return xml_response(document)


@blueprint.route("/lookup")
def lookup():
    """The contact's name for ?number=, or an empty body. For asterisk's CURL()."""
    number = normalise(request.args.get("number", ""))
    name = next((n for n, num in load() if num == number), "") if number else ""
    return Response(name, mimetype="text/plain"), 200
