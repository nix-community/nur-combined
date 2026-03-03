{
  pkgs,
  ...
}:
let
  inherit (pkgs.callPackage ../lib { inherit pkgs; }) callPackage;
in
rec {
  cxadc-vhs-server = callPackage ./cxadc-vhs-server { };
  cxadc-vhs-server-jitterbug = callPackage ./cxadc-vhs-server/jitterbug.nix {
    inherit cxadc-vhs-server;
  };
  tbc-raw-stack = callPackage ./tbc-raw-stack { };
  tbc-video-export = callPackage ./tbc-video-export { };
  vhs-decode-auto-audio-align = callPackage ./vhs-decode-auto-audio-align {
    inherit binah;
  };

  # deps
  binah = callPackage ./deps/binah { };
}
