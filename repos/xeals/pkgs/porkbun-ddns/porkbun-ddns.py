#!@python@/bin/python

import argparse
import json
import os
import re
import requests
from dataclasses import dataclass, fields as datafields
from enum import Enum, unique
from typing import List, Optional

APIBASE = "https://api.porkbun.com/api/json/v3/dns"


def dataclass_from_dict(klass: object, d: dict):
    try:
        fieldtypes = {f.name: f.type for f in datafields(klass)}
        return klass(**{f: dataclass_from_dict(fieldtypes[f], d[f]) for f in d})
    except:
        return d  # Not a dataclass field


def remove_domain(domain: str, name: str):
    return re.sub(f"\\.?{domain}$", "", name)


@unique
class RecordType(Enum):
    a = "A"
    aaaa = "AAAA"
    cname = "CNAME"
    mx = "MX"
    srv = "SRV"
    txt = "TXT"


@dataclass
class Record:
    id: str
    name: str
    type: str
    content: str
    ttl: str
    prio: str = ""
    notes: str = ""


@dataclass
class Retrieval:
    status: str
    records: List[Record]


class ApiError(Exception):
    pass


class ArgumentError(Exception):
    pass


class PorkbunClient:
    def __init__(self, apikey: str, secretapikey: str):
        self.apikey = apikey
        self.secretapikey = secretapikey

    def _make_payload(self, **kwargs):
        return json.dumps(
            {"apikey": self.apikey, "secretapikey": self.secretapikey, **kwargs}
        )

    def edit_record(
        self,
        domain: str,
        record: Record,
        name: Optional[str] = None,
        type: Optional[RecordType] = None,
        content: Optional[str] = None,
        ttl: Optional[int] = None,
        priority: Optional[str] = None,
    ) -> bool:
        return self.edit(
            domain,
            record.id,
            name=name or record.name,
            type=type or RecordType(record.type),
            content=content or record.content,
            ttl=ttl or record.ttl,
            priority=priority or record.prio,
        )

    def edit(
        self,
        domain: str,
        id: str,
        name: str,
        type: RecordType,
        content: str,
        ttl: int = 300,
        priority: Optional[str] = None,
    ) -> bool:
        # API returns FQN name rather than the actual prefix, so scrub it
        name = remove_domain(domain, name)
        payload = self._make_payload(
            name=name, type=type.value, content=content, ttl=str(ttl), prio=priority
        )
        res = requests.post(f"{APIBASE}/edit/{domain}/{id}", data=payload)
        body = res.json()
        if body["status"] != "SUCCESS":
            raise ApiError(body["message"])
        return True

    def delete(self, domain: str, id: str) -> bool:
        payload = self._make_payload()
        res = requests.post(f"{APIBASE}/delete/{domain}/{id}", data=payload)
        body = res.json()
        if body["status"] != "SUCCESS":
            raise ApiError(body["message"])
        return True

    def retrieve(self, domain: str) -> List[Retrieval]:
        payload = self._make_payload()
        res = requests.post(f"{APIBASE}/retrieve/{domain}", data=payload)
        body = res.json()
        if body["status"] != "SUCCESS":
            raise ApiError(body["message"])
        return [dataclass_from_dict(Record, d) for d in body["records"]]


def current_ip() -> str:
    return requests.get("https://ifconfig.me").text


def _load_key(key: Optional[str], keyfile: Optional[str]) -> str:
    if keyfile is not None:
        with open(keyfile) as f:
            return f.read().strip()
    if key is not None:
        return key
    raise ArgumentError("key or key file is required")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Wrapper around Porkbun DNS API")
    keyarg = parser.add_mutually_exclusive_group(required=True)
    keyarg.add_argument("-k", "--key", metavar="KEY", type=str, help="API key")
    keyarg.add_argument(
        "-K", "--key-file", metavar="FILE", type=str, help="API key file"
    )
    secretarg = parser.add_mutually_exclusive_group(required=True)
    secretarg.add_argument(
        "-s", "--secret", metavar="SECRET", type=str, help="secret API key"
    )
    secretarg.add_argument(
        "-S", "--secret-file", metavar="FILE", type=str, help="secret API key file"
    )
    parser.add_argument("domains", type=str, nargs="+", help="domain(s) to update")

    args = parser.parse_args()
    try:
        apikey = _load_key(args.key, args.key_file)
        secretapikey = _load_key(args.secret, args.secret_file)
    except Exception as e:
        print("error: " + str(e))
        parser.print_help()
        exit(1)

    current_ip = current_ip()
    client = PorkbunClient(apikey, secretapikey)
    for domain in args.domains:
        recs = client.retrieve(domain)
        arecs = [r for r in recs if r.type == RecordType.a.value]
        for arec in arecs:
            if arec.content != current_ip:
                client.edit_record(domain, arec, content=current_ip)
                print(f"Pointed '{arec.name}' to {current_ip}")
