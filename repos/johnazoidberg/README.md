# nur-packages

These are my personal nix packages, overlays, modules and functions which I chose to share with the community in hope of providing value to others :)

Some of them are only useful to me and a handful of people, others are in the process of being tested by myself and others before starting a pull request for nixpkgs.

This repository is inspired by and a part of [NUR](https://github.com/nix-community/NUR), the Nix User Repository - instructions on how to use it are available on their project site.

## Contents

### Functions
`aes-cbc` can decrypt a string at evaluation time. This allows to push nix configurations with secrets to a public git. Note: The decrypted string will be stored in cleartext in the `/nix/store`!

### Modules
`cpupower` can automatically turn the frequency governor to `performance` when plugged into power and back to `powersave` when unplugged again.

`ip-to-usb` allows you to configure a headless host to write its IP-address configuration to a USB drive on plugging it in for a few seconds.
Optionally the USB drive is required to provide authentication.

### Overlays
None yet

### Packages
My own package for transforming a youtube channel or playlist into a podcast RSS feed
[youtuberss](https://github.com/JohnAZoidberg/youtuberss)

TPM 2.0 tools and library by Intel
- [tpm2-tools](https://github.com/tpm2-software/tpm2-tools)
- [tpm2-tss](https://github.com/tpm2-software/tpm2-tss)

Libraries and tools for Thai language
- [thpronun](https://github.com/tlwg/thpronun) Thai pronunciation analyzer
- [libthai](https://github.com/tlwg/libthai) Thai language support library
- [libdatrie](https://github.com/tlwg/libdatrie) Double-Array Trie Library

[Okernel](https://github.com/linux-okernel/linux-okernel)
- `okernel-procps-src` Forked `ps` with okernel column
- `okernel-procps-patch` Patched `ps` with okernel column
- `okernel-htop` Forked `htop` with okernel column
- `okernel` Okernel userspace [components](https://github.com/linux-okernel/linux-okernel-components) and supporting material

## Available attributes
```
.lib.aes-cbc
.modules.cpupower
.modules.ip-to-usb

.eprover

.rfc-reader

.youtube-rss

.tpm2-tools
.tpm2-tss

.libdatrie
.libthai
.thpronun

.okernel-procps-src
.okernel-procps-patch
.okernel-procps-package
.okernel-htop
.okernel
```
