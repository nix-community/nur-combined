{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "yafg";
  version = "0-unstable-2026-01-10";

  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "yafg.yazi";
    rev = "dd03b133d6cd1ff92368360558da193517169f9e";
    hash = "sha256-xTZ+6KRr85A4QpPWAE9QN1AnUVnCw/tvRvsWOmmayao=";
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
