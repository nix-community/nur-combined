{ mkDerivation, base, blaze-html, lib, sqlite-simple, unix, fetchFromGitHub}:
mkDerivation {
  pname = "qutebrowser-start-page";
  version = "0.1.0.0";
  src = fetchFromGitHub {
    rev = "1e7757a856ed5acd73bc1ea66d1073b255dac6fd";
    owner = "afreakk";
    repo = "qutebrowser-start-page";
    sha256 = "sha256-2egOtTFS5RpdFN5M0wqO3s5esvQ4EaB2Mgdvxn0b9yY=";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base blaze-html sqlite-simple unix ];
  license = "unknown";
  hydraPlatforms = lib.platforms.none;
}
