# See <https://github.com/josh/systemd-age-creds/blob/main/nix/systemd-age-creds.nix>
{
  lib,
  buildGoModule,
  fetchFromGitHub,
  age,
  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "systemd-age-creds";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "systemd-age-creds";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+pgTuWzfFGnwL58htlyN13nccffqiSAQlTjhIP+M6UA=";
  };

  vendorHash = null;

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.AgeBin=${lib.getExe age}"
  ];

  nativeBuildInputs = [ age ];

  postInstall = ''
    substituteInPlace ./systemd/*.service --replace-fail /usr/sbin/systemd-age-creds $out/bin/systemd-age-creds
    install -D --mode=0444 --target-directory $out/lib/systemd/system ./systemd/*
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

    help =
      runCommand "test-systemd-age-creds-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
        ''
          systemd-age-creds --help
          touch $out
        '';
  };

  meta = {
    description = "Load age encrypted credentials in systemd units";
    mainProgram = "systemd-age-creds";
    homepage = "https://github.com/josh/systemd-age-creds";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
