{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-resource-monitor";
  version = "0-unstable-2026-05-15";

  src = fetchFromGitHub {
    owner = "YoungJurry";
    repo = "dms-resource-monitor";
    rev = "5e5f9d60f00a0f6fe2b9b515d729c27edeb510c5";
    hash = "sha256-JX9livc8l78lFA4spGaEoYXRcAgClYsnIITc6kYrhTs=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell DankBar widget showing real-time CPU, memory and swap usage with circular progress indicators";
    homepage = "https://github.com/YoungJurry/dms-resource-monitor";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
