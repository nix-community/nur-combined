{ stdenv, fetchFromGitHub, ... }:
stdenv.mkDerivation rec {
  name = "material";
  version = "1.4.2";
  src = fetchFromGitHub {
    owner = "LeonStaufer";
    repo = "material-dokuwiki";
    rev = "v${version}";
    hash = "sha256-jCcvIE4xjSXOxXVSTpq4Jn7xCOGOAvra+ua3c/sUlnw=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}
