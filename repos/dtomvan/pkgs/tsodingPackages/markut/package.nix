{
  lib,
  nix-update-script,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "markut";
  version = "0-unstable-2025-04-25";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "markut";
    rev = "4ea2951a94ca8407e4c52e17834904e9e20e761a";
    hash = "sha256-Fr41mydYfafnwKZgaI7MEI7TIM5Zs4zDZOLtzSrh2B4=";
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
