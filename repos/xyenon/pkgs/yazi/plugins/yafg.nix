{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  pname = "yafg";
  version = "0-unstable-2026-10-05";
  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "yafg.yazi";
    rev = "1202b2ca9ebb7bf537927ba07df1aa96ff532502";
    hash = "sha256-CsJuHn4L6rhsrTKFzIuQWtDp0uj+kUsCri1UogMA2n0=";
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
