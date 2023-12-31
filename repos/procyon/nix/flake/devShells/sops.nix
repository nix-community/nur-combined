# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ ... }:
{
  perSystem = { pkgs, ... }: {
    devShells.sops = pkgs.mkShell {
      name = "sops-shell";

      packages = with pkgs; [
        age
        sops
        ssh-to-age
        ssh-to-pgp
      ];
    };
  };
}
