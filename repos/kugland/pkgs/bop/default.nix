{ pkgs, lib, stdenvNoCC, fetchFromGitHub }:
stdenvNoCC.mkDerivation rec {
  pname = "bop";
  version = "20250124";

  src = fetchFromGitHub {
    owner = "zealtv";
    repo = "bop";
    tag = version;
    hash = "sha256-z6DgURAYw4hnuY1mYhUWB4Gre/DyikEmyxtaCoBG60M=";
  };

  installPhase = ''
    runHook preInstall
    cp -r . $out/
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/zealtv/bop";
    description = "friendly modules for pure data vanilla. bop 🐤 is suited to embedded, distributed, and miscellaneous digital musical applications.";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.kugland ];
  };
}
