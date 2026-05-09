{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  pname = "clipboard";
  version = "0-unstable-2026-05-08";
  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "clipboard.yazi";
    rev = "bda3e093fa3950ca1106a407d65ad30255d9d240";
    hash = "sha256-s74faAFyUX7CC6lTxf0UAcq6KZeoxtaoqWDIFjhnxoI=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Clipboard sync plugin for Yazi that copies yanked file paths to the system clipboard";
    homepage = "https://github.com/XYenon/clipboard.yazi";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ xyenon ];
  };
}
