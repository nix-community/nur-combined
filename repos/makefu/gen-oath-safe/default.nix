{ coreutils, makeWrapper, openssl, libcaca, qrencode, fetchFromGitHub, yubikey-manager, python, stdenv, ... }:

stdenv.mkDerivation {
  name = "gen-oath-safe-2017-06-30";
  src = fetchFromGitHub {
    owner = "mcepl";
    repo = "gen-oath-safe";
    rev = "fb53841";
    sha256 = "0018kqmhg0861r5xkbis2a1rx49gyn0dxcyj05wap5ms7zz69m0m";
  };

  phases = [
    "unpackPhase"
    "installPhase"
    "fixupPhase"
  ];

  buildInputs = [ makeWrapper ];

  installPhase =
    let
      path = stdenv.lib.makeBinPath [
        coreutils
        openssl
        qrencode
        yubikey-manager
        libcaca
        python
      ];
    in
    ''
      mkdir -p $out/bin
      cp gen-oath-safe $out/bin/
      wrapProgram $out/bin/gen-oath-safe \
        --prefix PATH : ${path}
    '';
}
