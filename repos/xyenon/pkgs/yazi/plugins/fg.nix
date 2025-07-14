{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fg";
  version = "0-unstable-2025-07-10";

  src = fetchFromGitHub {
    owner = "DreamMaoMao";
    repo = "fg.yazi";
    rev = "0c6ae0b52a0aa40bb468ca565c34ac413d1f93c1";
    hash = "sha256-pFljxXAyUfu680+MhbLrI07RcukrPXgmIvtp3f6ZVvY=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Yazi plugin for rg search with fzf file preview";
    homepage = "https://github.com/DreamMaoMao/fg.yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
