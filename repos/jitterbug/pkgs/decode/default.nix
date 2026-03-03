{
  pkgs,
  ...
}:
let
  inherit (pkgs.callPackage ../lib { inherit pkgs; }) callPackage;
in
rec {
  ld-decode = callPackage ./ld-decode {
    inherit ezpwd-reed-solomon;
  };
  ld-decode-unstable = callPackage ./ld-decode/unstable.nix {
    inherit ezpwd-reed-solomon;
  };
  vhs-decode = callPackage ./vhs-decode {
    inherit ezpwd-reed-solomon qwt-qt6;
  };
  vhs-decode-unstable = callPackage ./vhs-decode/unstable.nix {
    inherit ezpwd-reed-solomon qwt-qt6;
  };
  vhs-decode-testing = callPackage ./vhs-decode/testing.nix {
    inherit ezpwd-reed-solomon;
  };

  # deps
  ezpwd-reed-solomon = callPackage ./deps/ezpwd-reed-solomon { };
  qwt-qt5 = callPackage ./deps/qwt {
    qt = pkgs.qt5;
  };
  qwt-qt6 = callPackage ./deps/qwt {
    qt = pkgs.qt6;
  };
}
