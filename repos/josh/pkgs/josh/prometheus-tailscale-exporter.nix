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
  pname = "prometheus-tailscale-exporter";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tailscale_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IDy6AmVysNjSLjWvO3Cs+AQflpl1s3P27YzF3XeuWow=";
  };

  vendorHash = "sha256-KyA4s1FyWpwnnCGXT72fKJyCKbpXmG3vOscG1jFqR90=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  postInstall = lib.strings.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace ./systemd/*.service --replace-fail /usr/bin/tailscale_exporter $out/bin/tailscale_exporter
    install -D --mode=0444 --target-directory $out/lib/systemd/system ./systemd/*
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

    help =
      runCommand "test-prometheus-tailscale-exporter-help"
        { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
        ''
          tailscale_exporter --help
          touch $out
        '';
  };

  meta = {
    description = "Prometheus exporter for Tailscale metrics";
    homepage = "https://github.com/josh/tailscale_exporter";
    license = lib.licenses.mit;
    mainProgram = "tailscale_exporter";
  };
})
