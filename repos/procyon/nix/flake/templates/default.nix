# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ self, lib, ... }:
let
  mkTemplate = name: {
    description = "${name} [Project]";
    path = "${self}/nix/templates/${lib.strings.toLower name}";
  };
in
{
  flake.templates = {
    rust = mkTemplate "Rust";
  };
}
