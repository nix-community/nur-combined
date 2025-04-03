{
  fetchFromGitHub,
  stdenvNoCC,
  lib,
}:
stdenvNoCC.mkDerivation {
  name = "kanagawa-yazi";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "dangooddd";
    repo = "kanagawa.yazi";
    rev = "31167ed54c9cc935b2fa448d64d367b1e5a1105d";
    hash = "sha256-phwGd1i/n0mZH/7Ukf1FXwVgYRbXQEWlNRPCrmR5uNk=";
  };

  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/dangooddd/kanagawa.yazi";
    description = "kanagawa.yazi flavour";
    platforms = platforms.all;
  };
}
