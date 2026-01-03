{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "nautilus-taildrop";
  version = "0-unstable-2025-12-31";

  src = fetchFromGitHub {
    owner = "bahorn";
    repo = "nautilus-taildrop";
    rev = "8d50273a2fae863267321eba67932ae947ed467e";
    hash = "sha256-dOT4wjhXpD6kUxaJ0hjJz4czaWl2KDgUELE3svREAag=";
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
