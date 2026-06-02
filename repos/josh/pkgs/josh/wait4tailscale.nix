{
  lib,
  buildGoModule,
  fetchFromGitHub,
  coreutils,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "wait4tailscale";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "wait4tailscale";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OhwYQfuN67Itr1OCmJz+a6eihIeFcDPGRsWOHDVG8Mc=";
  };

  vendorHash = "sha256-XBEF+agJ3t30UJufzFmkSuoNA5vpFA3Dsbz7Un+tObM=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  postInstall = ''
    substituteInPlace ./systemd/*.service \
      --replace-fail /usr/bin/wait4tailscale $out/bin/wait4tailscale \
      --replace-fail /usr/bin/rm ${coreutils}/bin/rm
    install -D --mode=0444 --target-directory $out/lib/systemd/system ./systemd/*
  '';

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

    help = runCommand "test-wait4tailscale-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
      wait4tailscale --help
      touch $out
    '';
  };

  meta = {
    description = "Monitor Tailscale connection status";
    homepage = "https://github.com/josh/wait4tailscale";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "wait4tailscale";
  };
})
