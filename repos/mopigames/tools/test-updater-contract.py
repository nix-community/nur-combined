#!/usr/bin/env python3
"""Static contract checks for the signed A/B updater."""

from pathlib import Path
import os
import subprocess


ROOT = Path(__file__).resolve().parents[1]


def text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


installer = text("config/includes.chroot/usr/local/bin/moonlight-install")
updater_path = ROOT / "config/includes.chroot/usr/local/sbin/moonlight-update"
updater = updater_path.read_text(encoding="utf-8")
grub_path = ROOT / "config/includes.chroot/etc/grub.d/09_moonlight_slots"
grub = grub_path.read_text(encoding="utf-8")
backup = text("config/includes.chroot/usr/local/bin/moonlight-backup")
slot_sync_path = ROOT / "config/includes.chroot/usr/local/sbin/moonlight-slot-sync"
slot_sync = slot_sync_path.read_text(encoding="utf-8")
workflow = text(".github/workflows/iso.yml")
timer = text(
    "config/includes.chroot/etc/systemd/system/moonlight-update-confirm.timer"
)

for label in ("moonlight-boot", "moonlight-root-a", "moonlight-root-b"):
    assert label in installer, f"installer does not create {label}"
    assert label in updater or label == "moonlight-boot", f"updater misses {label}"

assert "GRUB_DEFAULT=saved" in text("config/includes.chroot/etc/default/grub")
assert "--id 'moonlight-$slot'" in grub
assert "uuid_for_label moonlight-root-a" in grub
assert "uuid_for_label moonlight-root-b" in grub
assert "grub-reboot \"moonlight-$INACTIVE_SLOT\"" in updater
assert "grub-set-default \"moonlight-$CURRENT_SLOT\"" in updater
assert "OnBootSec=90s" in timer

verify_at = updater.index("openssl pkeyutl -verify")
parse_at = updater.index("AVAILABLE_VERSION=$(manifest_value version)")
download_at = updater.index('curl --proto', parse_at)
format_at = updater.index("mkfs.ext4")
assert verify_at < parse_at < download_at < format_at

restore_at = updater.index('moonlight-backup --restore-to')
rewrite_at = updater.index("write_slot_files", restore_at)
assert restore_at < rewrite_at
assert "/etc/moonlight-os\n" not in backup
assert "/etc/moonlight-os/moonlight-os.conf" in backup
assert "/etc/moonlight-os/.configured" in backup
assert "/usr/share/moonlight-os/release" in slot_sync
assert "/usr/share/moonlight-os/release" in text("build.sh")
assert "moonlight-slot-sync.service" in text(
    "config/hooks/normal/0050-moonlight-updater.hook.chroot"
)

for asset in ("moonlight-os-update.txt", "moonlight-os-update.txt.sig"):
    assert asset in workflow
assert "moonlight-os-update.txt" in updater
assert "SIGNATURE_URL=${MANIFEST_URL}.sig" in updater
assert "UPDATE_CHANNEL" in updater
assert "UPDATE_CHANNEL=\"stable\"" in text(
    "config/includes.chroot/etc/moonlight-os/moonlight-os.conf"
)
assert "r.get(\"prerelease\") and not r.get(\"draft\")" in updater
assert 'MANIFEST_URL="$RELEASES_URL/download/$AVAILABLE_TAG/$MANIFEST_NAME"' in updater
assert 'url="$RELEASES_URL/download/${AVAILABLE_TAG}/${AVAILABLE_ISO}"' in updater
assert 'manifest_tag=$(manifest_value tag)' in updater
assert 'manifest_tag" != "$AVAILABLE_TAG' in updater
assert "format=2\\nversion=%s\\ntag=%s" in workflow
assert "${version/-beta./~beta.}" in workflow
assert '--prerelease' in workflow

assert "MLOS_UPDATE_SIGNING_KEY" in workflow
assert os.stat(updater_path).st_mode & 0o111
assert os.stat(ROOT / "tools/test-updater-channel.py").st_mode & 0o111
assert os.stat(grub_path).st_mode & 0o111
assert os.stat(slot_sync_path).st_mode & 0o111

public_key = ROOT / "config/includes.chroot/usr/share/moonlight-os/update.pub"
subprocess.run(
    ["openssl", "pkey", "-pubin", "-in", str(public_key), "-noout"],
    check=True,
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL,
)

print("Moonlight OS updater contract: ok")
