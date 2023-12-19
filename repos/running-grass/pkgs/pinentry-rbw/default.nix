{ stdenv
, lib
, pkgs
, jq
, coreutils
, rbw
, ...
}:

stdenv.mkDerivation rec {
  pname = "pinentry-rbw";
  version = "0.1.0";
  name = "pinentry-rbw-${version}";
  src = ./.;
  installPhase = ''\
    install -Dm755 -t $out/bin  pinentry-rbw
    substituteInPlace $out/bin/pinentry-rbw \
      --replace jq ${jq}/bin/jq \
      --replace head ${coreutils}/bin/head \
      --replace rbw ${rbw}/bin/rbw \
  '';
}