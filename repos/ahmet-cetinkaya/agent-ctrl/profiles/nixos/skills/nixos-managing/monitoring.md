---
name: monitoring
description: Lightweight health-check / alerting pattern for NixOS hosts using a systemd timer + Telegram (or any webhook). Covers filesystem, disk, SMART, services, microVMs, OOM and kernel errors.
---

# Monitoring & Alerts on NixOS

Battle-tested pattern used on the `pi` host: a single systemd timer runs a shell script every 15 minutes, checks health signals, and pushes alerts to Telegram. Dedup via hash files so you get **one** alert per incident and a **resolve** message when it clears.

No Prometheus, no node_exporter, no Grafana — just `systemd.timers` + `curl`. Good fit for single hosts / small home-labs where a heavy stack is overkill.

## What it detects

| # | Signal | How |
|---|---|---|
| 1 | Btrfs device errors | `btrfs device stats /persist` — any non-zero counter |
| 2 | Btrfs scrub errors | `btrfs scrub status` — grep error summary |
| 3 | Low disk space | `btrfs filesystem usage` free estimate < threshold |
| 4 | QEMU VM paused/crashed | QMP `info status` over UNIX socket |
| 5 | microVMs down | `systemctl is-active microvm@*` |
| 6 | Critical services down | `systemctl is-active tailscaled sshd smb ...` |
| 7 | NVMe SMART failure | `smartctl -H /dev/nvme0n1` — failed / non-zero critical warning |
| 8 | OOM kills | `journalctl -k` grep "out of memory" in last 15 min |
| 9 | Kernel errors | `journalctl -k -p err` in last 15 min |

Extend by adding more sections — pattern is copy-paste friendly.

## Core design

**Three helpers:**
- `send_telegram` — raw POST to Bot API
- `send_alert KEY MSG` — send once per unique KEY (touches a hash file under `/tmp/monitor-alerts`, skips if it already exists)
- `clear_alert KEY MSG` — if the hash file exists, remove it and send a 🟢 "resolved" message

This gives you **edge-triggered** alerts: you notice when things break *and* when they recover, without repeated spam.

**Why `/tmp` and not `/var/lib`:**
Alerts should re-fire after a reboot — `/tmp` being volatile is a feature here.

## Skeleton module

```nix
{ config, pkgs, lib, ... }:

let
  telegramBotToken = "REPLACE_OR_READ_FROM_AGENIX";   # see Secrets section below
  telegramChatId   = "REPLACE";

  monitorScript = pkgs.writeShellScript "system-monitor" ''
    set -euo pipefail
    PATH="${lib.makeBinPath (with pkgs; [
      coreutils curl gnugrep gawk
      btrfs-progs smartmontools
      socat systemd util-linux
    ])}"

    HASH_DIR="/tmp/monitor-alerts"
    mkdir -p "$HASH_DIR"

    send_telegram() {
      local msg="$1"
      curl -s -X POST "https://api.telegram.org/bot${telegramBotToken}/sendMessage" \
        -d chat_id="${telegramChatId}" \
        -d parse_mode=HTML \
        -d text="$msg" >/dev/null 2>&1 || true
    }

    send_alert() {
      local key="$1" msg="$2"
      local hash; hash=$(echo -n "$key" | md5sum | cut -d' ' -f1)
      [ -f "$HASH_DIR/$hash" ] && return
      touch "$HASH_DIR/$hash"
      send_telegram "$msg"
    }

    clear_alert() {
      local key="$1" msg="$2"
      local hash; hash=$(echo -n "$key" | md5sum | cut -d' ' -f1)
      if [ -f "$HASH_DIR/$hash" ]; then
        rm -f "$HASH_DIR/$hash"
        send_telegram "$msg"
      fi
    }

    # --- checks go here ---
    # Example: btrfs errors
    ERRS=$(btrfs device stats /persist 2>/dev/null | grep -v ' 0$' || true)
    if [ -n "$ERRS" ]; then
      send_alert "btrfs-errors" "🔴 <b>host: btrfs errors</b>
<pre>$ERRS</pre>"
    else
      clear_alert "btrfs-errors" "🟢 <b>host: btrfs errors — OK</b>"
    fi
  '';
in
{
  systemd.services."system-monitor" = {
    description = "System health monitor with Telegram alerts";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${monitorScript}";
    };
  };

  systemd.timers."system-monitor" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec      = "2min";
      OnUnitActiveSec = "15min";
      Persistent     = true;
    };
  };
}
```

## Useful patterns to copy from `pi/modules/monitoring.nix`

- **Hourly-rotating keys** for volume-heavy events (OOM, kernel errors):
  `send_alert "oom-$(date +%Y%m%d%H)" ...` — gives you at most one alert per hour per class, without manual dedup.
- **`|| true`** after every check command — the script runs under `set -e`, and you do **not** want the first empty `grep` to kill the whole monitor.
- **`lib.makeBinPath`** instead of hardcoded paths — the script is still usable when `/run/current-system/sw/bin` isn't in PATH (e.g. called by systemd with a clean env).

## Secrets

**Do not commit the bot token into the flake.** Read it with agenix/sops:

```nix
age.secrets.telegram-monitor.file = ../secrets/telegram-monitor.age;

# inside the script, replace the let-binding with:
#   telegramBotToken=$(cat ${config.age.secrets.telegram-monitor.path})
# and ensure the service has access:
systemd.services."system-monitor".serviceConfig.LoadCredential =
  [ "telegram:${config.age.secrets.telegram-monitor.path}" ];
```

See the secret-management section of [SKILL.md](SKILL.md) for agenix vs sops-nix.

## Operational notes

- **Test before relying on it:** `systemctl start system-monitor.service` once, check `journalctl -u system-monitor`, verify a message lands in Telegram.
- **Force a resolve:** remove `/tmp/monitor-alerts/<hash>` and rerun — on the next clean pass you'll get the 🟢 message.
- **List active alerts:** `ls /tmp/monitor-alerts/` — each file = one unresolved incident.
- **Silence during maintenance:** `systemctl stop system-monitor.timer` (alerts resume on next boot because `Persistent = true` catches up missed runs).

## When to outgrow this

Move to Prometheus + Alertmanager (or Netdata / Uptime Kuma) when you need:
- Multi-host aggregation
- Historical graphs / trend alerts ("disk filling at X GB/day")
- On-call rotation / escalation
- Alert routing by severity

For a single host, this script is ~150 lines, zero extra services, and zero maintenance.
