{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,

  jq,

  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-restic-exporter";
  version = "2.1.0";

  outputs = [
    "out"
    "grafana"
  ];

  src = fetchFromGitHub {
    owner = "josh";
    repo = "restic-exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-X/+NVmgaCQflGaCIiXwSWMfkCh91/sSkRLr9mpeqNq4=";
  };

  vendorHash = "sha256-GvnrQjGxmjgeAF7nwZlqsQJvPjMw95fEwdhjo/fSFow=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  postInstall =
    lib.strings.optionalString stdenv.hostPlatform.isLinux ''
      substituteInPlace ./systemd/*.service --replace-fail /usr/bin/restic-exporter $out/bin/restic-exporter
      install -D --mode=0444 --target-directory $out/lib/systemd/system ./systemd/*
    ''
    + ''

      mkdir $grafana
      cp -R ./grafana/* $grafana/
    '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

    grafana-json =
      runCommand "test-prometheus-restic-exporter-grafana-json" { nativeBuildInputs = [ jq ]; }
        ''
          readarray -t files < <(find ${finalAttrs.finalPackage.grafana} -name '*.json')
          [ "''${#files[@]}" -gt 0 ]
          jq --exit-status . "''${files[@]}" >/dev/null
          touch $out
        '';
  };

  meta = {
    description = "Prometheus exporter for Restic metrics";
    homepage = "https://github.com/josh/restic-exporter";
    license = lib.licenses.mit;
    mainProgram = "restic-exporter";
  };
})
