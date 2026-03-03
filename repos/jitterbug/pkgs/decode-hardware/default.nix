{
  pkgs,
  ...
}:
let
  inherit (pkgs.callPackage ../lib { inherit pkgs; }) callPackage;
in
rec {
  cxadc = callPackage ./cxadc {
    kernel = pkgs.linuxPackages.kernel;
  };
  domesdayduplicator = callPackage ./domesdayduplicator { };
  misrc-tools = callPackage ./misrc-tools {
    inherit hsdaoh;
  };
  misrc-tools-unstable = callPackage ./misrc-tools/unstable.nix {
    inherit misrc-tools;
    hsdaoh = hsdaoh-unstable;
  };

  # deps
  hsdaoh = callPackage ./deps/hsdaoh { };
  hsdaoh-unstable = callPackage ./deps/hsdaoh/unstable.nix { inherit hsdaoh; };
}
