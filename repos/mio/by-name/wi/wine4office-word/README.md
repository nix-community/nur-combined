# Wine4Office and Microsoft Word

Build Wine and the Word installer/launcher:

```sh
nix build .#wine4office .#wine4office-word
```

`wine4office-install-word` installs 64-bit Microsoft 365 Word from Microsoft's
CDN into `~/.wine4office`, matching the Wine prefix's Windows language with an
English fallback. Supply `--configuration FILE` to change
the language, product or channel for your licence. `--setup FILE` accepts an
already extracted Office Deployment Tool `setup.exe`.

Run `wine4office-word` to launch Word. Installation does not activate Office;
sign in with an appropriately licensed account when prompted.

## VM tests

The sandboxed smoke test initializes a WoW64 prefix, checks both architectures,
runs a Windows command and checks the launcher's missing-installation error:

```sh
nix build .#checks.x86_64-linux.wine4office
```

The Word integration test downloads and installs real Microsoft Word in a fresh
graphical NixOS VM, opens an RTF document, checks for a visible document window
and repeats the launch. It saves installation and document screenshots.
Run its driver outside the Nix build sandbox because Microsoft's installer
requires internet access. This test needs KVM, about 8 GiB RAM, and space for
a 32 GiB VM disk; the Office download is several GiB.

```sh
nix build .#wine4office-word.tests.word.driver --out-link /tmp/wine4office-word-driver
mkdir -p /tmp/wine4office-word-test
cd /tmp/wine4office-word-test
/tmp/wine4office-word-driver/bin/nixos-test-driver
```

The live CDN test is intentionally separate from the offline flake check.
It checks installation and GUI startup, not account sign-in or activation.

The app exclusions follow Microsoft's
[ODT configuration reference](https://learn.microsoft.com/en-us/microsoft-365-apps/deploy/office-deployment-tool-configuration-options).
