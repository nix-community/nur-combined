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

`prosody-filer` is a server which supports XEP-0363 together with Prosody's [`mod_http_upload_external`](https://modules.prosody.im/mod_http_upload_external.html)

### Overlays
None yet

### Packages
- [caas](https://github.com/iNPUTmice/caas) Check if an XMPP server is compliant (XEP-0387)
- `pppconfig` Configure pppd to connect to the Internet
- [prosody-filer](https://github.com/ThomasLeister/prosody-filer) Golang `mod_http_upload_external` server for Prosody
- [multivault](https://github.com/Selfnet/multivault) Simple CLI to manage distributed secrets for ansible
- [rederr](https://github.com/poettering/rederr) Colour your stderr red
- [isabelle2018](https://isabelle.in.tum.de/) 2018 version of Isabelle
- [u-root](https://github.com/u-root/u-root) A fully Go userland! u-root can create a root file system (initramfs) containing a busybox-like set of tools written in Go
- [uefi-driver-wizard](https://github.com/tianocore/tianocore.github.io/wiki/UEFI-Driver-Wizard) Program designed to accelerate the development of new UEFI drivers using a GUI-based template generator
- [rfc-reader](https://github.com/monsieurh/rfc_reader) CLI RFC reader

- [python-oath](https://github.com/bdauvergne/python-oath) Python implementation of HOTP, TOTP and OCRA algorithms from OATH
- [python-vipaccess](https://github.com/dlenski/python-vipaccess) A free software implementation of Symantec's VIP Access application and protocol

- [voctomix](https://github.com/voc/voctomix) Full-HD Software Live-Video-Mixer in python
- [fbset](http://users.telenet.be/geertu/Linux/fbdev) Show and modify frame buffer device settings

Terminal image viewers
- [timg](https://github.com/hzeller/timg/)
- [tiv](https://github.com/stefanhaustein/TerminalImageViewer/releases)

Python3 Modules
- [hk4py](https://github.com/Selfnet/hkp4py) Library to get GPG/PGP keys from a Keyserver

My own package for transforming a youtube channel or playlist into a podcast RSS feed
- [youtuberss](https://github.com/JohnAZoidberg/youtuberss)

Libraries and tools for Thai language
- [thpronun](https://github.com/tlwg/thpronun) Thai pronunciation analyzer

## Available attributes
```
.lib.aes-cbc

.modules.cpupower
.modules.ip-to-usb
.modules.prosody-filer

.caas

.pppconfig

.prosody-filer

.python3Packages.hkp4py

.multivault

.rederr

.python-oath

.python-vipaccess

.fbset

.voctomix

.isabelle2018

.timg

.u-root

.uefi-driver-wizard


.rfc-reader

.youtube-rss

.tpm2-tools
.tpm2-tss

.thpronun
```
