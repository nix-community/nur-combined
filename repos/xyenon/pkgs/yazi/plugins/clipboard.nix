{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "clipboard";
  version = "0-unstable-2026-02-10";

  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "clipboard.yazi";
    rev = "3b9681091b783d6bc5d07172afd6159060a7db63";
    hash = "sha256-8p2RC8F8JH1K36HebJM58stHX+lFLD+KYQxfdJm06y0=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Clipboard sync plugin for Yazi that copies yanked file paths to the system clipboard";
    homepage = "https://github.com/XYenon/clipboard.yazi";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
  };
}
