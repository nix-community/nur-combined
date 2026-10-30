#!/usr/bin/env python3
"""Send FusionSolar daily report email via production SMTP settings."""

from __future__ import annotations

import argparse
import json
import os
import smtplib
import ssl
import sys
from datetime import datetime
from email.message import EmailMessage
from pathlib import Path
from zoneinfo import ZoneInfo


def load_env(path: Path) -> dict[str, str]:
    env: dict[str, str] = {}
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env[key.strip()] = value.strip().strip('"').strip("'")
    return env


def parse_smtp_server(raw: str) -> tuple[str, int]:
    raw = raw.strip()
    if ":" in raw:
        host, port_s = raw.rsplit(":", 1)
        return host, int(port_s)
    return raw, 587


def format_go_now(tz_name: str = "America/Fortaleza") -> str:
    """Approximate Go time.Now().String() in the given zone, e.g. 2026-10-15 23:56:00 -0300 -03."""
    now = datetime.now(ZoneInfo(tz_name))
    offset = now.strftime("%z")  # +0300 / -0300
    # Go often prints zone abbr; use %Z which for ZoneInfo is typically -03
    zone = now.strftime("%Z") or offset[:3]
    return f"{now.strftime('%Y-%m-%d %H:%M:%S')} {offset} {zone}"


def build_body(station_kwh: dict[str, float | None], obtained_at: str) -> str:
    lines = ["Quantidade de energia produzida em cada base"]
    for name, kwh in station_kwh.items():
        if kwh is None:
            lines.append(f"{name}: Falha ao obter dados")
        else:
            lines.append(f"{name}: {kwh}kWh")
    lines.append("Os gráficos de geração estão em anexo.")
    lines.append(f"Dados obtidos em: {obtained_at}")
    return "\n".join(lines)


def send_report(
    date: str,
    station_kwh: dict[str, float | None],
    png_dir: Path,
    destinations: list[str],
    env_path: Path = Path(os.environ.get("FUSIONSOLAR_ENV", Path.home() / ".secrets/fusionsolar.env")),
) -> None:
    env = load_env(env_path)
    host, port = parse_smtp_server(env["SMTP_SERVER"])
    user = env["SMTP_USER"]
    password = env["SMTP_PASSWORD"]
    from_addr = env.get("SMTP_FROM") or user

    subject = f"Relatório do dia {date} FusionSolar"
    body = build_body(station_kwh, format_go_now())

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = from_addr
    msg["To"] = ", ".join(destinations)
    msg.set_content(body)

    for name in station_kwh:
        png_path = png_dir / f"{name}.png"
        if not png_path.is_file():
            raise FileNotFoundError(f"missing attachment: {png_path}")
        data = png_path.read_bytes()
        msg.add_attachment(
            data,
            maintype="image",
            subtype="png",
            filename=f"{name}.png",
        )

    context = ssl.create_default_context()
    with smtplib.SMTP(host, port, timeout=60) as smtp:
        smtp.ehlo()
        smtp.starttls(context=context)
        smtp.ehlo()
        smtp.login(user, password)
        smtp.send_message(msg)


def main() -> int:
    parser = argparse.ArgumentParser(description="Send FusionSolar daily report email")
    parser.add_argument("date", help="Report date YYYY-MM-DD")
    parser.add_argument(
        "station_json",
        help='JSON object of station name -> kWh (number) or null',
    )
    parser.add_argument("png_dir", help="Directory containing <station>.png files")
    parser.add_argument(
        "destinations",
        help="Comma-separated destination email addresses",
    )
    args = parser.parse_args()

    try:
        station_kwh = json.loads(args.station_json)
        if not isinstance(station_kwh, dict):
            raise ValueError("station_json must be a JSON object")
    except json.JSONDecodeError as e:
        print(f"Invalid station JSON: {e}", file=sys.stderr)
        return 2

    destinations = [d.strip() for d in args.destinations.split(",") if d.strip()]
    if not destinations:
        print("No destinations provided", file=sys.stderr)
        return 2

    try:
        send_report(
            date=args.date,
            station_kwh=station_kwh,
            png_dir=Path(args.png_dir),
            destinations=destinations,
        )
    except smtplib.SMTPException as e:
        print(f"SMTP error: {type(e).__name__}: {e}", file=sys.stderr)
        return 1
    except OSError as e:
        # Connection refused, network blocked, DNS, etc.
        print(f"Network/OS error: {type(e).__name__}: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Error: {type(e).__name__}: {e}", file=sys.stderr)
        return 1

    print("OK: email sent")
    return 0


if __name__ == "__main__":
    sys.exit(main())
