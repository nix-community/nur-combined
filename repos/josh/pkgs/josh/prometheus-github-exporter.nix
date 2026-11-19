{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-github-exporter";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "github_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7twCy8V/T1U0FNyvD9vvNHIoGi5iZEkVrSQS/xcacsk=";
  };

  vendorHash = "sha256-EyoVlZIwXUxQf75ryQ+nKbA2uG623IMvBkbLLrTnmnc=";

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

  };

  meta = {
    description = "Prometheus exporter for GitHub metrics";
    homepage = "https://github.com/josh/github_exporter";
    license = lib.licenses.mit;
    mainProgram = "github_exporter";
  };
})
