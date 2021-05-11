{ lib
, fetchFromGitLab
, python3
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "nvd";
  version = "0.0.1";

  src = fetchFromGitLab {
    owner = "khumba";
    repo = pname;
    rev = "7cdaa6d818119bd7a51930d990fded5d594c6623";
    sha256 = "0z8m48hq27mx2gm9s7p5ii79wp5asabgc67q8s90y6jirfh1y1vm";
  };

  sourceRoot = "source/src";

  buildInputs = [ python3 ];

  buildPhase = ''
    runHook preBuild
    gzip nvd.1
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -m555 -Dt $out/bin nvd
    install -m444 -Dt $out/share/man/man1 nvd.1.gz
    runHook postInstall
  '';

  meta = {
    description = "Nix/NixOS package version diff tool";
    homepage = "https://gitlab.com/khumba/nvd";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dschrempf ];
    platforms = lib.platforms.all;
  };
}
