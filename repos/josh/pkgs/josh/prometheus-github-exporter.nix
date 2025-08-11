{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-github-exporter";
  version = "1.1.0-unstable-2025-08-11";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "github_exporter";
    rev = "73cd6346af4b8b49e81b88d2069c5c363a0688f4";
    hash = "sha256-nJJ6C5l+fx9pj1UKEc0o0rrTCiTUQGC4kiGLp5tTEaQ=";
  };

  vendorHash = "sha256-6JOi1tu9IZhwEikgdSdLvbl9awmYTxqlcSVWHfs7Sqg=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  postInstall = ''
    substituteInPlace ./systemd/*.service --replace-fail /usr/bin/github_exporter $out/bin/github_exporter
    install -D --mode=0444 --target-directory $out/lib/systemd/system ./systemd/*
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

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
    platforms = lib.platforms.all;
    mainProgram = "github_exporter";
  };
})
