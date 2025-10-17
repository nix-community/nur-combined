{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "yafg";
  version = "0-unstable-2025-10-17";

  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "yafg.yazi";
    rev = "76fb63d9f29e3a4e9248535fb26c6321f65acdfe";
    hash = "sha256-GgOTTpo0KMffX2vkmEXhXNExFqZzDu0bfTkUL53pIUY=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Fuzzy find and grep plugin for Yazi file manager with interactive ripgrep/fzf search";
    homepage = "https://github.com/XYenon/yafg.yazi";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
  };
}
