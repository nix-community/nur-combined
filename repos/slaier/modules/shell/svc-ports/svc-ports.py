#!/usr/bin/env python3
import pwd
import subprocess


def main():
    print(f"{'PROTO':<5} {'ADDR:PORT':<22} {'SERVICE':<24} {'USER':<15}")
    print(f"{'-----':<5} {'----------------------':<22} {'------------------------':<24} {'---------------':<15}")

    try:
        out = subprocess.check_output(
            ["systemctl", "list-units", "--type=service", "--state=running", "--no-legend"],
            text=True,
        )
    except Exception as e:
        print(f"error: {e}")
        raise SystemExit(1)

    services = [line.split()[0] for line in out.splitlines() if line.strip()]

    user_to_services = {}
    for svc in services:
        try:
            user = subprocess.check_output(
                ["systemctl", "show", svc, "-p", "User"], text=True
            ).split("=", 1)[1].strip()
        except Exception:
            user = ""
        user_to_services.setdefault(user or "(root)", []).append(svc)

    try:
        ss = subprocess.check_output(["ss", "-tuln"], text=True)
    except Exception:
        ss = ""

    addr_map = {}
    for line in ss.splitlines():
        if "LISTEN" not in line:
            continue
        parts = line.split()
        if len(parts) >= 5:
            addr = parts[4]
            try:
                port = int(addr.rsplit(":", 1)[-1].strip("[]"))
                addr_map[port] = addr
            except Exception:
                pass

    seen = set()
    rows = []

    for path in ["/proc/net/tcp", "/proc/net/tcp6"]:
        try:
            with open(path) as f:
                for line in f.readlines()[1:]:
                    parts = line.split()
                    if len(parts) < 10:
                        continue
                    if parts[3] != "0A":
                        continue
                    try:
                        port = int(parts[1].split(":")[1], 16)
                    except Exception:
                        continue
                    uid = parts[7]
                    try:
                        user = pwd.getpwuid(int(uid)).pw_name
                    except Exception:
                        user = uid

                    cand = user_to_services.get(user, [])
                    if len(cand) == 1:
                        svc = cand[0]
                    elif uid == "0":
                        # ponytail: root disambiguation via known port, use sudo for exact pid->unit
                        svc = "sshd.service" if port == 22 else "(root)"
                        if svc == "(root)":
                            continue
                    else:
                        continue

                    if svc not in services:
                        continue

                    key = (port, svc)
                    if key in seen:
                        continue
                    seen.add(key)
                    addr = addr_map.get(port, f"*:{port}")
                    rows.append((port, addr, svc, user))
        except FileNotFoundError:
            continue

    for port, addr, svc, user in sorted(rows):
        print(f"tcp   {addr:<22} {svc:<24} {user:<15}")


if __name__ == "__main__":
    main()
