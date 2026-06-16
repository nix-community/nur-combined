{
  lib,
  buildGoModule,
  fetchFromGitHub,
  restic,
  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-restic-exporter";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "restic-exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1RjiKFYTUYq3csV34z2BEEgJa4UxOi/7e0LC3QJYPNY=";
  };

  vendorHash = "sha256-6av04F+ViJyS9Or4Dx6iGPCSxNBs8Kmj9T9U6TD+P/g=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.resticBinary=${lib.getExe restic}"
    "-X main.resticVersion=${restic.version}"
  ];

  nativeCheckInputs = [
    restic
  ];

  outputs = [
    "out"
    "grafana"
  ];

  postInstall = ''
    substituteInPlace ./systemd/*.service --replace-fail /usr/bin/restic-exporter $out/bin/restic-exporter
    install -D --mode=0444 --target-directory $out/lib/systemd/system ./systemd/*

    mkdir $grafana
    cp -R ./grafana/* $grafana/
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

    help =
      runCommand "test-prometheus-restic-exporter-help"
        { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
        ''
          restic-exporter --help
          touch $out
        '';
  };

  meta = {
    description = "Prometheus exporter for Restic metrics";
    homepage = "https://github.com/josh/restic-exporter";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "restic-exporter";
  };
})
