import email
import email.policy
import ipaddress
import re
import sys
from concurrent.futures import ThreadPoolExecutor, wait

import dns.exception
import dns.resolver
import Milter
from publicsuffixlist import PublicSuffixList

SOCKET = sys.argv[1]
NAMESERVER, NAMESERVER_PORT = sys.argv[2], int(sys.argv[3])

IP_ZONES = [
    "zen.spamhaus.org",
    "bl.spamcop.net",
    "b.barracudacentral.org",
    "dnsbl-1.uceprotect.net",
    "dnsbl-2.uceprotect.net",
    "dnsbl-3.uceprotect.net",
    "ips.backscatterer.org",
    "psbl.surriel.com",
    "bl.mailspike.net",
    "z.mailspike.net",
    "all.spamrats.com",
    "hostkarma.junkemailfilter.com",
    "all.s5h.net",
    "bl.0spam.org",
    "rbl.0spam.org",
    "nbl.0spam.org",
    "truncate.gbudb.net",
    "dnsbl.justspam.org",
    "bl.blocklist.de",
    "rbl.interserver.net",
    "bl.nordspam.com",
    "bl.spameatingmonkey.net",
    "dnsbl.spfbl.net",
    "list.dnswl.org",
]
DOMAIN_ZONES = [
    "dbl.spamhaus.org",
    "multi.surbl.org",
    "multi.uribl.com",
    "dbl.nordspam.com",
]
MAX_DOMAINS = 20
MAX_BODY = 2 * 1024 * 1024
HEADER = "X-DNSBL"

SPAMHAUS_ERR = {252: "typo", 254: "public-resolver", 255: "over-limit"}


def last(code):
    return int(code.rsplit(".", 1)[1])


def bits(names):
    def f(code):
        n = last(code)
        if n == 1:
            return "blocked"
        return "+".join(v for k, v in names.items() if n & k) or None

    return f


def spamhaus(names):
    def f(code):
        if code.startswith("127.255.255."):
            return SPAMHAUS_ERR.get(last(code))
        return names.get(last(code))

    return f


DECODE = {
    "zen.spamhaus.org": spamhaus(
        {
            2: "sbl",
            3: "css",
            4: "xbl",
            5: "xbl",
            6: "xbl",
            7: "xbl",
            9: "drop",
            10: "pbl-isp",
            11: "pbl",
        }
    ),
    "dbl.spamhaus.org": spamhaus(
        {
            2: "spam",
            4: "phish",
            5: "malware",
            6: "c2",
            102: "abused-spam",
            103: "abused-redirector",
            104: "abused-phish",
            105: "abused-malware",
            106: "abused-c2",
        }
    ),
    "multi.uribl.com": bits({2: "black", 4: "grey", 8: "red"}),
    "multi.surbl.org": bits({8: "phish", 16: "malware", 64: "abuse", 128: "cracked"}),
    "all.spamrats.com": lambda c: {36: "dyna", 37: "noptr", 38: "spam", 43: "auth"}.get(
        last(c)
    ),
    "hostkarma.junkemailfilter.com": lambda c: (
        {1: "white", 2: "black", 3: "yellow", 4: "brown", 5: "nobl"}.get(last(c))
        if c.startswith("127.0.0.")
        else None
    ),
    "list.dnswl.org": lambda c: "blocked" if c == "127.0.0.255" else f"trust{last(c)}",
}

psl = PublicSuffixList()
resolver = dns.resolver.Resolver(configure=False)
resolver.nameservers = [NAMESERVER]
resolver.port = NAMESERVER_PORT
resolver.lifetime = 5
pool = ThreadPoolExecutor(max_workers=64)

URL_RE = re.compile(r"""https?://(?:[^/\s"'<>@]*@)?([^/\s"'<>?#:\\]+)""", re.I)
ADDR_RE = re.compile(r"@([^@\s<>\"']+?)>?\s*$")


def reg_domain(host):
    host = host.strip().strip(".").lower()
    if not host:
        return None
    try:
        ipaddress.ip_address(host.strip("[]"))
        return None
    except ValueError:
        pass
    try:
        host = host.encode("idna").decode("ascii")
    except UnicodeError:
        return None
    return psl.privatesuffix(host)


def lookup(name):
    try:
        ans = resolver.resolve(name, "A")
        return sorted(r.address for r in ans)
    except (dns.resolver.NXDOMAIN, dns.resolver.NoAnswer):
        return []
    except dns.exception.DNSException as e:
        return "error(" + type(e).__name__ + ")"


def fmt_codes(zone, codes):
    dec = DECODE.get(zone)
    out = []
    for c in codes:
        label = dec(c) if dec else None
        out.append(f"{c}({label})" if label else c)
    return ",".join(out)


class DnsblMilter(Milter.Base):
    def __init__(self):
        self.ip = None
        self.rdns = None
        self.helo = None
        self.reset()

    def reset(self):
        self.mailfrom = None
        self.hfrom = None
        self.body_chunks = []
        self.body_len = 0
        self.headers = []

    def connect(self, hostname, family, hostaddr):
        try:
            self.ip = ipaddress.ip_address(hostaddr[0])
        except (ValueError, TypeError, IndexError):
            self.ip = None
        if hostname and not hostname.startswith("["):
            self.rdns = hostname
        return Milter.CONTINUE

    def hello(self, heloname):
        self.helo = heloname
        return Milter.CONTINUE

    def envfrom(self, mailfrom, *args):
        self.reset()
        self.mailfrom = mailfrom
        return Milter.CONTINUE

    def header(self, name, val):
        self.headers.append((name, val))
        if name.lower() == "from" and self.hfrom is None:
            self.hfrom = val
        return Milter.CONTINUE

    def body(self, chunk):
        if self.body_len < MAX_BODY:
            self.body_chunks.append(chunk)
            self.body_len += len(chunk)
        return Milter.CONTINUE

    def body_domains(self):
        raw = b"".join(
            f"{n}: {v}\r\n".encode("utf-8", "surrogateescape") for n, v in self.headers
        )
        raw += b"\r\n" + b"".join(self.body_chunks)
        msg = email.message_from_bytes(raw, policy=email.policy.default)
        hosts = []
        for part in msg.walk():
            if part.get_content_maintype() != "text":
                continue
            try:
                text = part.get_content()
            except Exception:
                text = part.get_payload(decode=True) or b""
                text = text.decode("latin-1")
            hosts.extend(m.group(1) for m in URL_RE.finditer(text))
        return hosts

    def collect_domains(self):
        hosts = []
        for addr in (self.mailfrom, self.hfrom):
            if addr:
                m = ADDR_RE.search(addr)
                if m:
                    hosts.append(m.group(1))
        hosts += [self.helo or "", self.rdns or ""]
        try:
            hosts += self.body_domains()
        except Exception as e:
            print(f"body parse failed: {e!r}", file=sys.stderr)
        domains = []
        for h in hosts:
            d = reg_domain(h)
            if d and d not in domains:
                domains.append(d)
        return domains[:MAX_DOMAINS]

    def eom(self):
        try:
            self.add_results()
        except Exception as e:
            print(f"eom failed: {e!r}", file=sys.stderr)
        return Milter.CONTINUE

    def add_results(self):
        domains = self.collect_domains()
        check_ip = self.ip is not None and self.ip.is_global
        futures = {}
        if check_ip:
            rev = self.ip.reverse_pointer.rsplit(".", 2)[0]
            for z in IP_ZONES:
                futures[(z, None)] = pool.submit(lookup, f"{rev}.{z}")
        for z in DOMAIN_ZONES:
            for d in domains:
                futures[(z, d)] = pool.submit(lookup, f"{d}.{z}")
        wait(futures.values(), timeout=10)

        def res(key):
            f = futures[key]
            return f.result() if f.done() else "error(Timeout)"

        lines = [
            "ip={}{} rdns={} helo={} domains={}".format(
                self.ip,
                "" if check_ip else "(skipped)",
                self.rdns or "-",
                self.helo or "-",
                ",".join(domains) or "-",
            )
        ]
        hits = []
        if check_ip:
            for z in IP_ZONES:
                r = res((z, None))
                if isinstance(r, str):
                    lines.append(f"{z}={r}")
                elif r:
                    lines.append(f"{z}={fmt_codes(z, r)}")
                    hits.append(z)
                else:
                    lines.append(f"{z}=-")
        for z in DOMAIN_ZONES:
            parts = []
            for d in domains:
                r = res((z, d))
                if isinstance(r, str):
                    parts.append(f"{d}:{r}")
                elif r:
                    parts.append(f"{d}:{fmt_codes(z, r)}")
            if parts:
                hits.append(z)
            lines.append(f"{z}={' '.join(parts) or '-'}")

        for i, line in enumerate(lines):
            self.addheader(HEADER, line, i)
        qid = self.getsymval("i") or "?"
        print(
            f"{qid}: ip={self.ip} domains={len(domains)} hits={','.join(hits) or '-'}",
            file=sys.stderr,
        )


def main():
    Milter.factory = DnsblMilter
    Milter.set_flags(Milter.ADDHDRS)
    Milter.runmilter("dnsbl", SOCKET, timeout=300)


if __name__ == "__main__":
    main()
