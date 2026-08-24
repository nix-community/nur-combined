# Updating Helios

Windows service installations can check for and install signed Helios releases
from the Home page in the local Web UI. Update installation is deliberately
manual: Helios never downloads or applies a release until an authenticated Web
UI user selects **Install update** and confirms the restart.

Before offering a release, Helios verifies the exact `helios-update.json` bytes
with the embedded Ed25519 public key. The signed manifest must match the GitHub
release tag, prerelease flag, archive name, archive size, and archive SHA-256.
Helios then downloads `helios-windows-x86_64.zip` over HTTPS and verifies both
its size and SHA-256 before starting the service handoff.

The updater expands the archive into a new sibling directory, copies the local
`config` directory, stops `HeliosService`, and points the service at the new
`heliossvc.exe`. It considers the update healthy only when the service is
running, the expected `Helios.exe` is running from the new directory, and the
Web UI port accepts a connection. If that check fails, the service path is
restored to the previous installation and the old service is started again.

The previous installation and update staging directory are retained. This is
intentional: automatic cleanup would remove the rollback evidence and make a
failed update harder to diagnose. The handoff log is stored alongside the
downloaded update archive as `apply-update.log`.

Built-in installation currently requires Windows and an installed
`HeliosService`. Linux and macOS builds report that the built-in installer is
unavailable and can still be updated with their package manager or a release
package.

## Release signing

Tagged CI builds create the updater archive, a compact manifest, and a raw
64-byte Ed25519 signature. The private signing key is supplied only through the
`HELIOS_UPDATE_SIGNING_KEY` GitHub Actions secret. It must never be committed or
placed in a release asset.

The embedded public-key fingerprint (SHA-256 of SubjectPublicKeyInfo DER) is:

```text
4bd718f0eb22f33f7a7d06324b7e610d191d17696e8b879c5b5cefcdab03e614
```

If the signing key is lost or suspected to be compromised, generate a new key,
replace the embedded public key and GitHub secret together in a normal reviewed
release, and document the rotation. Existing binaries cannot trust releases
signed only by a replacement key, so key rotation requires a transition build
that trusts both the old and new identities or a manual update.
