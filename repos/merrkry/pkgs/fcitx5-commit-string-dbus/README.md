# fcitx5-commit-string-dbus

This package provides a small standalone Fcitx 5 addon that exposes a
D-Bus method for committing text into the current input context.

## Attribution

The implementation in this directory was ported as a standalone addon for
nixpkgs/NUR packaging, based on the `commitstringdbus` module found in the
openKylin `fcitx5` source tree:

- <https://gitee.com/openkylin/fcitx5/tree/openkylin/nile/src/modules/commitstringdbus>

The original openKylin module is Copyright 2024 KylinSoft Co., Ltd. and is
distributed under GPL-3.0-or-later.

This repository may use MIT for its Nix packaging material, but that does
not change the license of the ported addon source in this package directory.
The C++ addon sources here should be treated as GPL-3.0-or-later-derived
code, while the surrounding Nix packaging expressions are separate
packaging glue.

## Notes

The upstream openKylin code was written as an in-tree Fcitx 5 module. This
package restructures it into a small standalone addon build so it can link
against nixpkgs' packaged `fcitx5` and be installed through the normal
`fcitx5` addon mechanism.
