{
  lib,
  nix-update-script,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "markut";
  version = "0-unstable-2026-04-26";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "markut";
    rev = "7256f271dfb8510d45da5245a67d28216e2e3b2f";
    hash = "sha256-GxymBrdKzeh1hJr43ymVfMsc5dmBWyS6pow5xWew5yg=";
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
