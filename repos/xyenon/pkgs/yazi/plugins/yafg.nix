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
    rev = "6034c67ebefa7c0fd749f68b8200660c17481e3b";
    hash = "sha256-seRvfkD/jC4LJJUqgkBeIAd8BGBka+s5z4XWSaxhCvE=";
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
