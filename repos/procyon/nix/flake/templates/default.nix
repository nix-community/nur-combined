# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ self, lib, ... }:
let
  mkTemplate = name: type: {
    description = "${name} [${type}]";
    path = "${self}/nix/templates/${lib.strings.toLower name}";
  };
in
{
  flake.templates = {
    rust-crane = mkTemplate "Rust" "Crane";
  };
}
