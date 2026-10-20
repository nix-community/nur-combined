"""Convert an inline OpenVPN profile to a sing-box JSON overlay, entirely offline."""

import argparse
import json
import shlex
import sys
import tempfile
from pathlib import Path


def convert(profile, tag="calculet"):
    directives = {}
    blocks = {}
    lines = iter(profile.read_text().splitlines())
    for line in lines:
        line = line.strip()
        if not line or line.startswith(("#", ";")):
            continue
        if line.startswith("<"):
            name = line[1:-1]
            if name not in {"ca", "cert", "key", "tls-crypt-v2"} or name in blocks:
                raise ValueError("unsupported or repeated inline block")
            content = []
            for value in lines:
                if value.strip() == f"</{name}>":
                    break
                content.append(value)
            else:
                raise ValueError("unterminated inline block")
            blocks[name] = "\n".join(content) + "\n"
            continue
        fields = shlex.split(line, comments=True)
        if fields:
            directives.setdefault(fields[0], []).append(fields[1:])

    # These client/runtime settings are managed internally by sing-box. In
    # particular, server-poll-timeout has no direct sing-box equivalent.
    ignored = {
        "client", "nobind", "persist-key", "persist-tun", "resolv-retry",
        "verb", "push-peer-info", "server-poll-timeout",
    }
    supported = {
        "remote", "remote-random", "proto", "dev", "dev-type", "cipher",
        "data-ciphers", "data-ciphers-fallback", "auth", "remote-cert-tls",
        "tls-version-min", "tls-version-max", "tun-mtu", "reneg-sec",
    }
    unsupported = directives.keys() - ignored - supported
    if unsupported:
        raise ValueError("unsupported directives: " + ", ".join(sorted(unsupported)))

    def option(name, default=None):
        values = directives.get(name)
        if values is None:
            return default
        if len(values) != 1 or len(values[0]) != 1:
            raise ValueError(f"expected one value for {name}")
        return values[0][0]

    def transport(value):
        # OpenVPN's tcp-client spellings are just tcp in sing-box.
        value = value.replace("tcp-client", "tcp").replace("-client", "")
        if value not in {"udp", "udp4", "udp6", "tcp", "tcp4", "tcp6"}:
            raise ValueError("unsupported OpenVPN transport")
        return value

    if option("dev", "tun") != "tun" or option("dev-type", "tun") != "tun":
        raise ValueError("only TUN profiles are supported")
    if blocks.keys() != {"ca", "cert", "key", "tls-crypt-v2"}:
        raise ValueError("expected inline CA, certificate, key and tls-crypt-v2")

    network = transport(option("proto", "udp"))
    servers = []
    for remote in directives.get("remote", []):
        if not 2 <= len(remote) <= 3:
            raise ValueError("remote must specify host, port and optional transport")
        port = int(remote[1])
        if not 1 <= port <= 65535:
            raise ValueError("invalid remote port")
        servers.append({
            "server": remote[0],
            "server_port": port,
            "network": transport(remote[2]) if len(remote) == 3 else network,
        })
    if not servers:
        raise ValueError("profile has no remote server")

    tls = {
        "certificate": blocks["ca"],
        "client_certificate": blocks["cert"],
        "client_key": blocks["key"],
        "remote_certificate_tls": option("remote-cert-tls", "server"),
        "version_min": option("tls-version-min", "1.2"),
        "control_wrap": {"type": "tls_crypt_v2", "key": blocks["tls-crypt-v2"]},
    }
    if "tls-version-max" in directives:
        tls["version_max"] = option("tls-version-max")
    endpoint = {
        "type": "openvpn-client",
        "tag": tag,
        "servers": servers,
        "remote_random": "remote-random" in directives,
        "tls": tls,
        # Learn company routes and split-DNS domains from the server. Do not
        # silently accept a full-tunnel policy while configured for split routing.
        "route_no_pull": False,
        "pull_filters": [{"action": "reject", "text": "redirect-gateway"}],
        "system": False,
        "on_demand": True,
    }
    if "tun-mtu" in directives:
        endpoint["mtu"] = int(option("tun-mtu"))
    if "reneg-sec" in directives:
        seconds = int(option("reneg-sec"))
        if seconds < 0:
            raise ValueError("negative renegotiation interval")
        if seconds == 0:
            endpoint["renegotiate_disabled"] = True
        else:
            endpoint["renegotiate_interval"] = f"{seconds}s"
    if "auth" in directives:
        endpoint["auth"] = option("auth")
    ciphers = option("data-ciphers", "AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305").split(":")
    # Legacy `cipher` is a TLS data-channel compatibility setting, not the
    # sing-box `cipher` field (which is only for static-key mode).
    legacy_cipher = option("cipher")
    if legacy_cipher and "data-ciphers" not in directives and legacy_cipher not in ciphers:
        ciphers.append(legacy_cipher)
    endpoint["data_ciphers"] = ciphers
    fallback = option("data-ciphers-fallback", legacy_cipher)
    if fallback:
        endpoint["data_ciphers_fallback"] = fallback
    return endpoint


def overlay(endpoint):
    tag = endpoint["tag"]
    dns_tag = f"{tag}-dns"
    return {
        "endpoints": [endpoint],
        "route": {
            "rules": [{"preferred_by": tag, "action": "route", "outbound": tag}],
        },
        "dns": {
            "servers": [{
                "type": "openvpn",
                "tag": dns_tag,
                "endpoint": tag,
                "accept_default_resolvers": False,
                "accept_search_domain": True,
            }],
            "rules": [{"preferred_by": dns_tag, "action": "route", "server": dns_tag}],
        },
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("profile", type=Path)
    parser.add_argument("--tag", default="calculet", help="endpoint tag (default: calculet)")
    parser.add_argument("-o", "--output", type=Path, help="write atomically with mode 0600")
    args = parser.parse_args()
    if not args.tag.strip():
        parser.error("--tag must not be empty")
    try:
        result = json.dumps(overlay(convert(args.profile, args.tag)), indent=2) + "\n"
        if args.output is None:
            sys.stdout.write(result)
        else:
            if args.output.resolve() == args.profile.resolve():
                raise ValueError("output must not overwrite the input profile")
            with tempfile.NamedTemporaryFile(
                mode="w", dir=args.output.parent, prefix=f".{args.output.name}.", delete=False
            ) as output:
                temporary = Path(output.name)
                try:
                    output.write(result)
                    output.close()
                    temporary.replace(args.output)
                finally:
                    temporary.unlink(missing_ok=True)
    except (OSError, ValueError) as error:
        sys.exit(f"Cannot convert OpenVPN profile: {error}")


if __name__ == "__main__":
    main()
