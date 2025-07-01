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
  version = "0.1.2-unstable-2025-06-30";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "github_exporter";
    rev = "b380cb61a0411fa44817c2ddc7d0af84fee4e6ca";
    hash = "sha256-4y6spoDfQm94dqziWL33mWnZghEzazhDeb/GGeWPMTM=";
  };

  vendorHash = "sha256-XoPS4oYYPxgbO7a54xH3gdG11adWlYmKe8IuGPtQdHc=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    version =
      let
        version-parts = lib.versions.splitVersion finalAttrs.version;
        stable-version = "${builtins.elemAt version-parts 0}.${builtins.elemAt version-parts 1}.${builtins.elemAt version-parts 2}";
      in
      testers.testVersion {
        package = finalAttrs.finalPackage;
        version = stable-version;
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
