{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  pname = "clipboard";
  version = "0-unstable-2026-07-19";
  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "clipboard.yazi";
    rev = "d4d19ea45836f279c0b99e1d234fe5ce4a154e4b";
    hash = "sha256-fawprH1+WysMcERWdCtgWulSHo4Pmu3eLLHbnKwvkIM=";
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
