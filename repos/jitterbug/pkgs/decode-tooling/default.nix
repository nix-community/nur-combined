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
  ld-decode-tools = callPackage ./ld-decode-tools {
    inherit ezpwd-reed-solomon;
  };
  tbc-raw-stack = callPackage ./tbc-raw-stack { };
  tbc-tools = callPackage ./tbc-tools {
    inherit ezpwd-reed-solomon qwt-qt6;
  };
  tbc-tools-unstable = callPackage ./tbc-tools/unstable.nix {
    inherit ezpwd-reed-solomon qwt-qt6;
  };
  tbc-video-export = callPackage ./tbc-video-export { };
  vhs-decode-auto-audio-align = callPackage ./vhs-decode-auto-audio-align {
    inherit binah;
  };
  vhs-decode-tools = callPackage ./vhs-decode-tools {
    inherit ezpwd-reed-solomon qwt-qt6;
  };
  vhs-decode-tools-unstable = callPackage ./vhs-decode-tools/unstable.nix {
    inherit ezpwd-reed-solomon qwt-qt6;
  };

  # deps
  binah = callPackage ./deps/binah { };
  ezpwd-reed-solomon = callPackage ./deps/ezpwd-reed-solomon { };
  qwt-qt5 = callPackage ./deps/qwt {
    qt = pkgs.qt5;
  };
  qwt-qt6 = callPackage ./deps/qwt {
    qt = pkgs.qt6;
  };
}
