# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/kugland/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-kugland-blue.svg)](https://kugland.cachix.org)

# Packages

- [auditok](./pkgs/auditok/): An audio/acoustic activity detection and audio segmentation tool.
- [ffsubsync](./pkgs/ffsubsync/): Automagically synchronize subtitles with video.
- [my-bookmarks-pl](./pkgs/my-bookmarks-pl/): Simple script to manage bookmarks in a text file and
  display them using rofi. **(Written by me)**
- [neocities-deploy](./pkgs/neocities-deploy/): CLI tool for deploying your Neocities site.
  **(Written by me)**
- [pysubs2](./pkgs/pysubs2/): A Python library for editing subtitle files.
- [subtitlecomposer](./pkgs/subtitlecomposer/): An open source text-based subtitle editor
  (from the KDE community) *This package has already been merged into* `nixpkgs`,
  *but I’m keeping it here because it is not in the stable channel yet.*

# Modules

## qemu-user-static

[**qemu-user-static**](./modules/qemu-user-static.nix) enables executing foreign-architecture
containers with QEMU and binfmt_misc (only available on `x86_64-linux`). This module pulls an OCI
container that automagically sets up the necessary configuration, and sets up an one-shot systemd
service to start the container on boot.

To use this module, add the following to your `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [ pkgs.nur.repos.kugland.modules.qemu-user-static ];
  virtualisation.qemu-user-static = {
    enable = true;
    autoStart = true; # If you want the container to start on boot
  };
}
```

To check if the module is working, try:

```sh
$ docker run --rm -it --platform linux/s390x alpine uname -m
```

If everything is set up correctly, you should see `s390x` printed to the terminal, which, unless
you actually have a s390x machine, means that the container is being executed with QEMU.

For more information, check out `qemu-user-static`’s [GitHub repository](https://github.com/multiarch/qemu-user-static).

# Overlays

## google-authenticator-singlesecret

**I’m not a security expert, so use this at your own risk.**

[**google-authenticator-singlesecret**](./overlays/google-authenticator-singlesecret/) is a patched
version of `google-authenticator-libpam` that hardcodes the options `secret`, `user` and
`echo_verification_code` as a workaround to the Nix module `security.pam` inability to pass
arbitrary options to the Google Authenticator PAM module. With the original configuration, you
can only use TOTP secrets stored at your own home directory and readable by your own user, which
makes it pointless for use with `sudo` (the secret is readable by your user *before* you acquire
privileges). In this version, the secret is stored at `/etc/my-secrets/google-authenticator/secret`,
and is only readable by the user `totp-auth`. This setup only makes sense if you have a single user
on your system.

I intend to make a module to configure this.

# License

All the Nix expressions in this repository are licensed under the [MIT license](./LICENSE).
The packages themselves are licensed under the licenses specified by their respective authors.
