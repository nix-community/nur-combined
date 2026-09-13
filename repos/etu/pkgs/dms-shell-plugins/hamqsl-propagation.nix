{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-hamqsl-propagation";
  version = "0-unstable-2026-07-04";

  src = fetchFromGitHub {
    owner = "devnullvoid";
    repo = "dms-hamqsl-propagation";
    rev = "92d57fd064869098530a6644b4416fe8d680e9f0";
    hash = "sha256-WGbbTv3mAMIBpsg76Ro+cJqVX/gQOBZnMjry6MuHfIM=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell DankBar widget showing HamQSL solar-terrestrial and ham radio propagation data, with compact bar modes and a detailed popout";
    homepage = "https://github.com/devnullvoid/dms-hamqsl-propagation";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
