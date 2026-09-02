{
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  lib,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustic-exporter";
  version = "0.1.0-rc.12";

  src = fetchFromGitHub {
    owner = "timtorChen";
    repo = "rustic-exporter";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-q2ZMBgOwf0pUXZpB/Jcj1nwdKH6JNKPYlayB/qwgstQ=";
  };

  cargoHash = "sha256-V8uBRDIQqB8CyOq+xUU+vrnSzVCUQgHjmyX1LMGjvOs=";

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--flake"
        "--version=unstable"
      ];
    };
  };

  meta = with lib; {
    mainProgram = "rustic-exporter";
    description = "Prometheus exporter for rustic/restic backup";
    homepage = "https://github.com/timtorChen/rustic-exporter";
    changelog = "https://github.com/timtorChen/rustic-exporter/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };

})
