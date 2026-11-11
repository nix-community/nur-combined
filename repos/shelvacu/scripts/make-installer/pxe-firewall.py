import json
import re
import subprocess
import sys


def run(*args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)


def nft_rules(chain="input-allow"):
    result = subprocess.run(
        ["nft", "--json", "list", "chain", "inet", "nixos-fw", chain],
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
    if not re.fullmatch(r"temp-vacu-make-installer-[1-9][0-9]*", tag):
        raise ValueError("Invalid firewall chain name")
    port = int(port)
    if not 1 <= port <= 65535:
        raise ValueError("Invalid HTTP port")
    if backend == "nftables":
        if action == "open":
            commands = (
                f"add chain inet nixos-fw {tag}\n"
                f"add rule inet nixos-fw {tag} udp dport {{ 67, 69, 4011 }} accept\n"
                f"add rule inet nixos-fw {tag} tcp dport {port} accept\n"
                f"insert rule inet nixos-fw input-allow jump {tag}\n"
            )
        else:
            commands = ""
            for entry in nft_rules() or []:
                rule = entry.get("rule", {})
                if any(
                    expr.get("jump", {}).get("target") == tag
                    for expr in rule.get("expr", [])
                ):
                    commands += f"delete rule inet nixos-fw input-allow handle {rule['handle']}\n"
            if nft_rules(tag) is not None:
                commands += f"flush chain inet nixos-fw {tag}\n"
                commands += f"delete chain inet nixos-fw {tag}\n"
        if commands:
            run("nft", "-f", "-", input=commands, text=True)
    elif backend == "iptables":
        # iptables limits chain names to 28 characters.
        chain = tag.replace("temp-vacu-make-installer-", "temp-vacu-installer-")
        jump = ["nixos-fw", "-j", chain]
        if action == "open":
            run("iptables", "-w", "-N", chain)
            for protocol, ports in [("udp", "67,69,4011"), ("tcp", str(port))]:
                run(
                    "iptables", "-w", "-A", chain,
                    "-p", protocol, "-m", "multiport", "--dports", ports,
                    "-j", "ACCEPT",
                )
            run("iptables", "-w", "-I", *jump)
        else:
            if (
                subprocess.run(
                    ["iptables", "-w", "-C", *jump], capture_output=True
                ).returncode == 0
            ):
                run("iptables", "-w", "-D", *jump)
            if (
                subprocess.run(
                    ["iptables", "-w", "-S", chain], capture_output=True
                ).returncode == 0
            ):
                run("iptables", "-w", "-F", chain)
                run("iptables", "-w", "-X", chain)
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
