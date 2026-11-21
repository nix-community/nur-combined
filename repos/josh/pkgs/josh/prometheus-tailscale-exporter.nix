{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-tailscale-exporter";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tailscale_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KxQM1GzNkCrgQA/xcROWiBscFhEjpvwZFyCl1FpU4qA=";
  };

  vendorHash = "sha256-T2gIf8LjxJVZGZ9LGUuIDcZ2ltbVPWnmVrdDSKsgM2I=";

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

  };

  meta = {
    description = "Prometheus exporter for Tailscale metrics";
    homepage = "https://github.com/josh/tailscale_exporter";
    license = lib.licenses.mit;
    mainProgram = "tailscale_exporter";
  };
})
