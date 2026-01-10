{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "ouch";
  version = "0.7.0-unstable-2026-01-09";

  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "594b8a2b246633d46b03a3261c9aebd1c4b5abf3";
    hash = "sha256-+M0ZFh2jKts5GP9KgKsbpeNe0ldXQGyUZlYjDbp4yhw=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Yazi plugin to preview archives";
    homepage = "https://github.com/ndtoan96/ouch.yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
