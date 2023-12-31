# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ inputs, ... }:
{
  perSystem = { system, lib, ... }:
    {
      devShells.rust =
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.rust-overlay.overlays.default ];
          };
        in
        pkgs.mkShell {
          name = "rust-shell";

          nativeBuildInputs = with pkgs; [ rust-analyzer ]
            ++ (lib.optional stdenv.isLinux lldb)
            ++ (lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.CoreFoundation);

          buildInputs = with pkgs; [ rust-bin.stable.latest.default ];
        };
    };
}
