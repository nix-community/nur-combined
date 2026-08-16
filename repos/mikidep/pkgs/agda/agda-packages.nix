{
  agdaPackages,
  fetchFromGitHub,
  ...
}: let
  mkCubicalVer = spec @ {
    version,
    hash,
    rev ? spec.version,
  }:
    agdaPackages.cubical.overrideAttrs (oldAttrs: {
      inherit version;
      src = fetchFromGitHub {
        repo = oldAttrs.pname;
        owner = "agda";
        inherit rev;
        inherit hash;
      };
    });
in {
  cubical-master = mkCubicalVer {
    version = "master";
    rev = "master";
    hash = "";
  };
  cubical-0_6 = mkCubicalVer {
    version = "0.6";
    hash = "";
  };
  cubical-0_7 = mkCubicalVer {
    version = "0.7";
    hash = "";
  };
  cubical-0_8 = mkCubicalVer {
    version = "0.8";
    hash = "";
  };
  cubical-0_9 = mkCubicalVer {
    version = "0.9";
    hash = "";
  };
}
