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
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tailscale_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NXDx2M8ML5yghcTt7CbpPtj7PgWNnT7Ieu6LZPsD+WY=";
  };

  vendorHash = "sha256-PK5XISqYhA++LzmB+AlRqP1JqrBaCGOUw6ByB03HCBQ=";

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
