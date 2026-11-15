{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-gitea-exporter";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "gitea_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hmPp1TEev/4yXT5Lz5cno3hSbA24z7Y3vfqm4FK0qZk=";
  };

  vendorHash = "sha256-+WzdK7LjCjaGlZezhCuf4RzGeob9qKlahNyN9YvzhQ4=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X github.com/prometheus/common/version.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };
  };

  meta = {
    description = "Prometheus exporter for Gitea pull requests and Actions workflow runs";
    homepage = "https://github.com/josh/gitea_exporter";
    license = lib.licenses.mit;
    mainProgram = "gitea_exporter";
  };
})
