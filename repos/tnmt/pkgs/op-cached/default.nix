{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "op-cached";
  version = "0.1.0-unstable-2026-08-25";

  src = fetchFromGitHub {
    owner = "joker1007";
    repo = "op-cached";
    rev = "a56e4848fb124802d642cbf969358fb64a242b45";
    hash = "sha256-DP/OcrENdp1lu4l4oQGIrowupwP7nHmdvUJjhibLY2Y=";
  };

  cargoHash = "sha256-9o3dy2a5UZRtx81mC+wfR8e6BFGGp3mdh5kCXy8RXVo=";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "GPG-encrypted in-memory cache daemon for 1Password CLI (op read / op inject)";
    homepage = "https://github.com/joker1007/op-cached";
    license = lib.licenses.mit;
    mainProgram = "op-cached";
    platforms = lib.platforms.unix;
  };
}
