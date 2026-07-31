{
  lib,
  buildGoModule,
  fetchFromGitHub,

  iperf3,
  makeWrapper,

  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-iperf3-exporter";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "edgard";
    repo = "iperf3_exporter";
    tag = finalAttrs.version;
    hash = "sha256-GZgSNBK0ka+m+GxPQUZIKG+6F3HkrGKo43fgh8CoFVs=";
  };

  vendorHash = "sha256-tA0lx6xOVLw5uZzxYXkAE6IpaW4WjaB25w/AsH4piw8=";

  nativeBuildInputs = [ makeWrapper ];

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X github.com/prometheus/common/version.Version=${finalAttrs.version}"
  ];

  postInstall = ''
    wrapProgram $out/bin/iperf3_exporter --prefix PATH : ${lib.strings.makeBinPath [ iperf3 ]}
  '';

  # Upstream switched from v-prefixed to bare numeric tags; the regex pins
  # the bare scheme so a stray v-tag cannot produce an unfetchable version
  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=stable"
      "--version-regex=^([0-9][0-9.]*)$"
    ];
  };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

    help =
      runCommand "test-prometheus-iperf3-exporter-help"
        { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
        ''
          iperf3_exporter --help
          touch $out
        '';

    iperf3-path = runCommand "test-prometheus-iperf3-exporter-iperf3-path" { } ''
      grep --text --quiet "${
        lib.strings.makeBinPath [ iperf3 ]
      }" "${lib.meta.getExe finalAttrs.finalPackage}"
      touch $out
    '';
  };

  meta = {
    description = "Server that probes iPerf3 endpoints and exports results via HTTP for Prometheus consumption";
    homepage = "https://github.com/edgard/iperf3_exporter";
    license = lib.licenses.asl20;
    mainProgram = "iperf3_exporter";
  };
})
