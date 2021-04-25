{ mkDerivation, base, blaze-html, lib, sqlite-simple, unix, fetchFromGitHub }:
mkDerivation {
  pname = "qutebrowser-start-page";
  version = "0.1.0.0";
  src = fetchFromGitHub {
    rev = "d1287c58dc8569c8bab34fb49f4599f246781311";
    owner = "afreakk";
    repo = "qutebrowser-start-page";
    sha256 = "18yr9qw6a2lyj0dfkby3d046agmb8hfkh738s2j1mrnw45a3lzsv";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base blaze-html sqlite-simple unix ];
  license = "unknown";
  hydraPlatforms = lib.platforms.none;
}
