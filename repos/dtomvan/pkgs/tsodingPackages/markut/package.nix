{
  lib,
  nix-update-script,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "markut";
  version = "0-unstable-2025-06-04";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "markut";
    rev = "c7e52821dcb9b247636e192da8b36c0245037b5d";
    hash = "sha256-RM5cjHcuXNkId0HLl32PTdzzzPQLJ1f7Fn0/fQIMhZY=";
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
