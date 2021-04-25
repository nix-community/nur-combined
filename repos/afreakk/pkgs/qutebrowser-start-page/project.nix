{ mkDerivation, base, blaze-html, lib, sqlite-simple, unix, fetchFromGitHub }:
mkDerivation {
  pname = "qutebrowser-start-page";
  version = "0.1.0.0";
  src = fetchFromGitHub {
    rev = "89ac16132388cdb8d9bdf8059645ab6da387b743";
    owner = "afreakk";
    repo = "qutebrowser-start-page";
    sha256 = "0yd8xr185mdilwj2qrxlgrkvxdqx551ylrxb9m2fsln4mgbkf9bd";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base blaze-html sqlite-simple unix ];
  license = "unknown";
  hydraPlatforms = lib.platforms.none;
}
