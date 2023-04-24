{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "mediawiki-tilesheets";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "FTB-Gamepedia";
    repo = "Tilesheets";
    rev = "${version}";
    sha256 = "sha256-NCgGOIGJhNkfR1/pdUzaLbkUXl6aizg5xICLy+Bfrr8=";
  };

  postInstall = ''

  mkdir -p $out/share/mediawiki/extensions/${pname}

  cp -r $src/* $out/share/mediawiki/extensions/${pname}
  '';

  meta = with lib; {
    description = "MediaWiki extension which adds a parser function that looks up a table for an item and returns the requested image.";
    homepage = "https://github.com/FTB-Gamepedia/Tilesheets";
    changelog = "https://github.com/FTB-Gamepedia/Tilesheets/blob/master/CHANGELOG.md";
    license = licenses.mit;
  };
}
