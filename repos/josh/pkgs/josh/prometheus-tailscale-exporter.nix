{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-tailscale-exporter";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tailscale_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MbcGiR+3fxAMmAibW7v85ozDI/E2nTJQ73H4U7ddTbA=";
  };

  vendorHash = "sha256-9Oqm6N2fZfmRBw0rhz3/YRKyw5KBA2kZjW+SjGbnx9w=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    substituteInPlace ./systemd/*.service --replace-fail /usr/bin/tailscale_exporter $out/bin/tailscale_exporter
    install -D --mode=0444 --target-directory $out/lib/systemd/system ./systemd/*
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

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
    platforms = lib.platforms.all;
    mainProgram = "tailscale_exporter";
  };
})
