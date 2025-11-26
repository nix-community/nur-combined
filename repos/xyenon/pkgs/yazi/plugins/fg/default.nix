{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fg";
  version = "0-unstable-2025-11-24";

  src = fetchFromGitHub {
    owner = "DreamMaoMao";
    repo = "fg.yazi";
    rev = "35b280524cc5ec838b6618c713cd40bb3588fb12";
    hash = "sha256-TyEX7wTDjvT6Z1rmFL0trEl8PF3MyetMb2a5s5aV3+4=";
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

  meta = with lib; {
    description = "Yazi plugin for rg search with fzf file preview";
    homepage = "https://github.com/DreamMaoMao/fg.yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
