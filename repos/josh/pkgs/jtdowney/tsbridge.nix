{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "tsbridge";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "jtdowney";
    repo = "tsbridge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1U6p0vUPI9hjKu+YQ9dD8QKh56TUIcPb9ZAMqC7oxF8=";
  };

  vendorHash = "sha256-2JyZY+Rr7x2/c68O4m3b3nN4/BUAS+IyrlR+wM1WbEE=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

    help =
      runCommand "test-systemd-age-creds-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
        ''
          tsbridge --help
          touch $out
        '';
  };

  meta = {
    description = "A lightweight proxy manager built on Tailscale's tsnet library that enables multiple HTTPS services on a Tailnet";
    mainProgram = "tsbridge";
    homepage = "https://github.com/jtdowney/tsbridge";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
