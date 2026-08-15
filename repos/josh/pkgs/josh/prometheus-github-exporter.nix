{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-github-exporter";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "github_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fisOYfIrkGriumbXQs05fD/TLg2ysoMHvHLnxG29PgU=";
  };

  vendorHash = "sha256-9D1EfO99sAtAJhi6oDRk1BQl4l3y85Bz85iQh2mxZp8=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  postInstall = lib.strings.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace ./systemd/*.service --replace-fail /usr/bin/github_exporter $out/bin/github_exporter
    install -D --mode=0444 --target-directory $out/lib/systemd/system ./systemd/*
  '';

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
    mainProgram = "github_exporter";
  };
})
