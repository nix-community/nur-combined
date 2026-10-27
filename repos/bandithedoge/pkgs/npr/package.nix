{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "npr";
  version = "0-unstable-2026-10-20";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "npr";
    rev = "f19f5001564538a9c1166c5ca9a8d346c5588afe";
    hash = "sha256-Tks8wyESKQ21rIEvk9aooXphBu/0sB/1x9Sh9IB8JYk=";
  };
  cargoHash = "sha256-MEyZ4E0FExOqzpWbmJCqDv6/gboFAnlo1kjPAqfMUQk=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Pull request tracker for Nixpkgs";
    homepage = "https://github.com/manic-systems/npr";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "npr";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
