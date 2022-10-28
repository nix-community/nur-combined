{
  stdenv,
  callPackage,
  lib,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  stdenv.mkDerivation {
    name = "fairfax-hd";
    version = source.date;
    src = callPackage ./source.nix {};
    preferLocalBuild = true;
    buildPhase = "true";
    installPhase = ''
      for variant in HD HaxHD PonaHD SMHD; do
        install -m444 -Dt $out/share/truetype/FairfaxHD FairfaxHD/Fairfax$variant.ttf
      done
    '';
    meta = {
      description = "Halfwidth scalable monospace font with support for many scripts, including Conscripts";
      license = lib.licenses.ofl;
    };
    passthru.updateScript = [
      ../../scripts/update-git.sh
      "https://gitlab.com/kreativekorp/open-relay.git"
      "fonts/kreative/source.json"
    ];
  }
