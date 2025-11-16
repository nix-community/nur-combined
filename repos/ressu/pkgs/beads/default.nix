{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkgs,
}:

buildGoModule rec {
  pname = "beads";
  version = "0.23.1";

  src = fetchFromGitHub {
    owner = "steveyegge";
    repo = "beads";
    rev = "v${version}";
    hash = "sha256-ibWPzNGUMk9NueWVR4xNS108ES2w1ulWL2ARB75xEig=";
  };

  vendorHash = "sha256-eUwVXAe9d/e3OWEav61W8lI0bf/IIQYUol8QUiQiBbo=";

  go = pkgs.go;
  doCheck = false;

  meta = with lib; {
    description = "Memory upgrade for your coding agent";
    homepage = "https://github.com/steveyegge/beads";
    license = licenses.mit;
    mainProgram = "bd";
  };
}
