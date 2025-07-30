{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fg";
  version = "0-unstable-2025-07-27";

  src = fetchFromGitHub {
    owner = "DreamMaoMao";
    repo = "fg.yazi";
    rev = "c201a3e1c0cda921c06019127886f16faef4b17e";
    hash = "sha256-PNZngyiWuzw2bmJ4v66er9HEAcD5z0Dr6iKYwcxJwf0=";
  };

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
