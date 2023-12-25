# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ self, ... }:
{
  perSystem = { pkgs, ... }: {
    checks.legal-reuse = pkgs.stdenvNoCC.mkDerivation {
      src = self;
      doCheck = true;
      dontBuild = true;
      name = "legal/reuse";
      checkPhase = "reuse lint";
      installPhase = "mkdir $out";
      nativeBuildInputs = with pkgs; [ reuse ];
    };
  };
}
