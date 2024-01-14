# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ self, lib, ... }:
let
  mkTemplate = name: type:
    let
      folder = with lib.strings; "${toLower name}-${toLower type}";
    in
    {
      description = "${name} [${type}]";
      path = "${self}/nix/templates/${folder}";
    };
in
{
  flake.templates = {
    rust-crane = mkTemplate "Rust" "Crane";
    rust-simple = mkTemplate "Rust" "Simple";
  };
}
