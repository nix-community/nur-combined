{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  pname = "fg";
  version = "0-unstable-2026-09-20";
  src = fetchFromGitHub {
    owner = "DreamMaoMao";
    repo = "fg.yazi";
    rev = "629ee224ab027a7dece548ebac3618a8a9b0bc16";
    hash = "sha256-ZoIYzXATPjLYSF7kH5UXgj6Ax1+HwL007iSG59x17qA=";
  };

  patches = [
    ./0001-Revert-fix-helix-open.patch
    ./0002-quote-file-url.patch
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Yazi plugin for rg search with fzf file preview";
    homepage = "https://github.com/DreamMaoMao/fg.yazi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xyenon ];
  };
}
