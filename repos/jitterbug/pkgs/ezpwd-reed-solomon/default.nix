{
  maintainers,
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  pname = "ezpwd-reed-solomon";
  version = "1.8.0-unstable-2024-10-2";

  rev = "62a490c13f6e057fbf2dc6777fde234c7a19098e";
  hash = "sha256-PC1KaJ7VkB4fKpcLsEqOaMxX1ZiowPWMstVjKx65zjg=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "pjkundert";
    repo = "ezpwd-reed-solomon";
    fetchSubmodules = true;
  };

  buildFlags = [
    "libraries"
  ];

  installPhase = ''
    mkdir -p $out/include
    cp -rL c++/ezpwd $out/include
    install -m755 -D libezpwd-bch.so $out/lib/libezpwd-bch.so
  '';

  meta = {
    inherit maintainers;
    description = "Reed-Solomon & BCH encoding and decoding, in C++, Javascript & Python.";
    homepage = "https://github.com/pjkundert/ezpwd-reed-solomon";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
