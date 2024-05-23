{
  lib,
  stdenvNoCC,
  fetchurl,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "metacubexd";
  version = "1.138.1";

  src = fetchurl {
    url = "https://github.com/MetaCubeX/metacubexd/releases/download/v${finalAttrs.version}/compressed-dist.tgz";
    hash = "sha256-l2mcb2optvgtfzma/Ix63Y8BxXC6CsGoyIIMoOvD074=";
  };

  dontConfigure = true;
  dontBuild = true;

  sourceRoot = ".";
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ./* $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Clash.Meta Dashboard, The Official One, XD";
    homepage = "https://github.com/MetaCubeX/metacubexd";
    license = lib.getLicenseFromSpdxId "MIT";
    platforms = lib.platforms.all;
  };
})
