{
  lib,
  nix-update-script,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "markut";
  version = "0-unstable-2025-09-01";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "markut";
    rev = "17235586b287b011e4b5d0a5378258c977561800";
    hash = "sha256-EoYh4WA3TH6f0FxMWeJ2/3mATCWZ8vCdU3qNMYq/ccU=";
  };

  vendorHash = null;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Autocut the Twitch VODs based on a Marker file";
    homepage = "https://github.com/tsoding/markut";
    license = lib.licenses.mit;
    mainProgram = "markut";
  };
}
