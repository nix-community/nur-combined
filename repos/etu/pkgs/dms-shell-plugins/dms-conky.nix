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
    rev = "9eaefc9077cddc5b260159b1ccbb73e2037573b6";
    hash = "sha256-wH8EpC2J1M0oTUIVwHZriT99Xs1HjjWIOO6a3sgP0ms=";
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
