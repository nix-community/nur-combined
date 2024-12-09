{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "nautilus-taildrop";
  version = "0-unstable-2024-01-12";

  src = fetchFromGitHub {
    owner = "bahorn";
    repo = "nautilus-taildrop";
    rev = "ed51d742b760447506030f564db6b59165e26518";
    hash = "sha256-353Ef2wfs6bVY+ZYl68vZynFdgXulfES8VdKVwXaUsY=";
  };

  dontBuild = true;

  installPhase = ''
    install -Dm644 taildrop.py -t "$out/share/nautilus-python/extensions"
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Taildrop support for Nautilus";
    homepage = "https://github.com/bahorn/nautilus-taildrop";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kira-bruneau ];
    mainProgram = "nautilus-taildrop";
    platforms = lib.platforms.all;
  };
}
