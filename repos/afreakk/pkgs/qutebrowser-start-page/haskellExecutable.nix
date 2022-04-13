{ mkDerivation, base, blaze-html, lib, sqlite-simple, unix, fetchFromGitHub }:
mkDerivation {
  pname = "qutebrowser-start-page";
  version = "0.1.0.0";
  src = fetchFromGitHub {
    rev = "a39ace3f47b72b77dc8a9a3925e373436935bbca";
    owner = "afreakk";
    repo = "qutebrowser-start-page";
    sha256 = "sha256-E38ip1Xdxq/9YBqAJxB1EGPereG2MMOaXsTY5w0MpnM=";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base blaze-html sqlite-simple unix ];
  license = "unknown";
  hydraPlatforms = lib.platforms.none;
}
