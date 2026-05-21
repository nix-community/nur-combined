{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  pname = "clipboard";
  version = "0-unstable-2026-05-20";
  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "clipboard.yazi";
    rev = "a125df07ba69c893df0e22592e55c1130ce16fe4";
    hash = "sha256-Q+8MGfeP7reX3nDl5V/HFxRYIayPKEQT5w0b+n73b5k=";
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
