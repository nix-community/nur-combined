{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-github-exporter";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "github_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-o53yNnUOSNR7yz16a7V1yF+ZaBrtmHXfCyNVQNC4dow=";
  };

  vendorHash = "sha256-XoPS4oYYPxgbO7a54xH3gdG11adWlYmKe8IuGPtQdHc=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

    help =
      runCommand "test-prometheus-github-exporter-help"
        { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
        ''
          github_exporter --help
          touch $out
        '';
  };

  meta = {
    description = "Prometheus exporter for GitHub metrics";
    homepage = "https://github.com/josh/github_exporter";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "github_exporter";
  };
})
