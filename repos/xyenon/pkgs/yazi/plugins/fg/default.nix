{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fg";
  version = "0-unstable-2026-01-03";

  src = fetchFromGitHub {
    owner = "DreamMaoMao";
    repo = "fg.yazi";
    rev = "b9fb819d2c407795d0e0678ef33f0dd0b2db8bb3";
    hash = "sha256-fgv7iNqx/4EMIcRGmXYY7Y+9/O+nZKeZtsbi0NQPCbw=";
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
