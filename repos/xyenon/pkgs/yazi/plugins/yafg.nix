{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  pname = "yafg";
  version = "0-unstable-2026-05-06";
  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "yafg.yazi";
    rev = "e6ba85125bfa4e3a60ef28b70949299712103b2a";
    hash = "sha256-IKQscTTirtfbsXKzCmaokPDrQZqXa4MSY2+6DbEQluU=";
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
