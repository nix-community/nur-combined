import json
import re
import subprocess
import sys


def run(*args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)


def nft_rules():
    result = subprocess.run(
        ["nft", "--json", "list", "chain", "inet", "nixos-fw", "input-allow"],
        capture_output=True,
        text=True,
    )
    if result.returncode:
        return None
    return json.loads(result.stdout)["nftables"]


def probe():
    if nft_rules() is not None:
        return "nftables"
    result = subprocess.run(["iptables", "-w", "-S", "nixos-fw"], capture_output=True)
    return "iptables" if result.returncode == 0 else "none"


def change(action, backend, tag, port):
    if not re.fullmatch(r"installer-pxe-[a-f0-9]+", tag):
        raise ValueError("Invalid firewall rule tag")
    port = int(port)
    if not 1 <= port <= 65535:
        raise ValueError("Invalid HTTP port")
    if backend == "nftables":
        if action == "open":
            run(
                "nft",
                "-f",
                "-",
                input=(
                    f'insert rule inet nixos-fw input-allow udp dport {{ 67, 69, 4011 }} accept comment "{tag}"\n'
                    f'insert rule inet nixos-fw input-allow tcp dport {port} accept comment "{tag}"\n'
                ),
                text=True,
            )
        else:
            for entry in nft_rules() or []:
                rule = entry.get("rule", {})
                if rule.get("comment") == tag:
                    run(
                        "nft",
                        "delete",
                        "rule",
                        "inet",
                        "nixos-fw",
                        "input-allow",
                        "handle",
                        str(rule["handle"]),
                    )
    elif backend == "iptables":
        for protocol, ports in [("udp", "67,69,4011"), ("tcp", str(port))]:
            rule = [
                "nixos-fw",
                "-p",
                protocol,
                "-m",
                "multiport",
                "--dports",
                ports,
                "-m",
                "comment",
                "--comment",
                tag,
                "-j",
                "ACCEPT",
            ]
            if action == "open":
                run("iptables", "-w", "-I", *rule)
            elif (
                subprocess.run(
                    ["iptables", "-w", "-C", *rule], capture_output=True
                ).returncode
                == 0
            ):
                run("iptables", "-w", "-D", *rule)
    else:
        raise ValueError("Unsupported firewall backend")


if __name__ == "__main__":
    if sys.argv[1:] == ["probe"]:
        print(probe())
    else:
        action, backend, tag, port = sys.argv[1:]
        if action not in ("open", "close"):
            raise ValueError("Invalid firewall action")
        change(action, backend, tag, port)
