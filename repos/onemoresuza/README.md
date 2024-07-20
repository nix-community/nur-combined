# NOTICE

This repository has been archived in favor of
[~onemoresuza/flake-pkgs](https://git.sr.ht/~onemoresuza/flake-pkgs) on [Sourcehut](https://sr.ht).

# nur-packages

[comment]: # "Remove this if you don't use github actions"
![Build and populate cache](https://github.com/onemoresuza/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[comment]: # "Remove this if you don't use cachix"
[comment]: # "Also, when using shields.io, replace '-' with '--'"
[![Cachix Cache](https://img.shields.io/badge/cachix-nur--onemoresuza-blue.svg)](https://nur-onemoresuza.cachix.org)

**My personal [NUR](https://github.com/nix-community/NUR) repository**

To have access to the binary cache, add the following to yout `nix.conf`:

```
trusted-public-keys = nur-onemoresuza.cachix.org-1:V109UI+YvFcaWXbxlPyw+of+7jnWoWuPPg5yg7BZQy0=
```

## Featured Packages

- **Mpv scripts**:
    1. [appendURL][appendURL]: *Appends url from clipboard to the playlist*.
- [IRust][irust]: *Cross Platform Rust Repl*.
- [Junest][junest]: *A lightweight Arch Linux based distro*.
- [PJeOffice][pjeoffice]: *CNJ software for digital signatures for the PJe system*.
- [aercbook][aercbook]: *A minimalistic address book for the aerc e-mail client*.
- [chawan][chawan]: *A text-mode web browser*.
- [pass-extension-tail][pass-extension-tail]: *A pass extension to avoid printing the password to the console*.
- [pass-sxatm][pass-sxatm]: *A simple X autofill tool with menu for pass*.
- [pdpmake][pdpmake]: *A public domain POSIX make*.

**NOTE**: these packages are built only against the `unstable` channels.

[aercbook]: <https://sr.ht/~renerocksai/aercbook/> "A minimalistic address book for the aerc e-mail client"
[appendURL]: <https://github.com/jonniek/mpv-scripts/> "Appends url from clipboard to the playlist"
[chawan]: <https://sr.ht/~bptato/chawan/> "A text-mode web browser"
[irust]: <https://github.com/sigmaSd/IRust/> "Cross Platform Rust Repl"
[junest]: <https://github.com/fsquillace/junest> "A lightweight Arch Linux based distro"
[pass-extension-tail]: <https://github.com/palortoff/pass-extension-tail> "A pass extension to avoid printing the password to the console"
[pass-sxatm]: <https://sr.ht/~onemoresuza/pass-sxatm/> "A simple X autofill tool with menu for pass"
[pdpmake]: <https://github.com/rmyorston/pdpmake> "A public domain POSIX make"
[pjeoffice]: <https://www.pje.jus.br/wiki/index.php/PJeOffice> "CNJ software for digital signatures for the PJe system"
[ttf-literation]: <https://www.nerdfonts.com/> "A ttf Nerd Font based on ttf-liberation"
