{ mkDerivation, base, blaze-html, lib, sqlite-simple, unix, fetchFromGitHub }:
mkDerivation {
  pname = "qutebrowser-start-page";
  version = "0.1.0.0";
  src = fetchFromGitHub {
    rev = "34d5dc49b33bd5a5d9885948401c665d7993929d";
    owner = "afreakk";
    repo = "qutebrowser-start-page";
    sha256 = "sha256-UU3SpYhD0lox0FpD8T7dIc+RQKbMqv5IMXE/Mie7MZg=";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base blaze-html sqlite-simple unix ];
  license = "unknown";
  hydraPlatforms = lib.platforms.none;
}
