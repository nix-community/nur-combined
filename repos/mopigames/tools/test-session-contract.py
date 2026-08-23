#!/usr/bin/env python3
"""Source-level contracts for unprivileged graphical session startup."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / "config/includes.chroot/usr/local/bin/moonlight-input"
SESSION = ROOT / "config/includes.chroot/usr/local/bin/moonlight-wlsession"


def main() -> None:
    input_source = INPUT.read_text(encoding="utf-8")
    session_source = SESSION.read_text(encoding="utf-8")

    assert "--apply-session) apply_session ;;" in input_source
    assert "moonlight-input --apply-session" in session_source
    assert "moonlight-input --apply\n" not in session_source


if __name__ == "__main__":
    main()
