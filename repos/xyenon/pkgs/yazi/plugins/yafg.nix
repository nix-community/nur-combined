{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  pname = "yafg";
  version = "0-unstable-2026-09-01";
  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "yafg.yazi";
    rev = "bd03a32e7de7c718c966e21f800c23bd26b717cb";
    hash = "sha256-8LKyY0GpvcOlWavcaWKfvh/nQzcHMrnLeoStRGHCXrk=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Fuzzy find and grep plugin for Yazi file manager with interactive ripgrep/fzf search";
    homepage = "https://github.com/XYenon/yafg.yazi";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ xyenon ];
  };
}
