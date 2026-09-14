{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dms-conky";
  version = "0-unstable-2026-09-14";

  src = fetchFromGitHub {
    owner = "suruibin";
    repo = "dms-conky";
    rev = "493e4d9191df0ef0c0e03fb7319d4ff19697f3f7";
    hash = "sha256-QBuIKnq3Lbjk6+kJnIhjInrn1RUi91UneJl3Q6b6xMY=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell classic Conky-style system monitor and app launcher";
    homepage = "https://github.com/suruibin/dms-conky";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
