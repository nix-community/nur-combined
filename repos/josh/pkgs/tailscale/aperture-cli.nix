{
  lib,
  buildGoModule,
  fetchFromGitHub,

  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "aperture-cli";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "aperture-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AIIqrDexPGWtFBTVvbiOagpvKR+HKoiKM3JhQcSWB4k=";
  };

  vendorHash = "sha256-LXkf5l52+7JflU39MY4aNwiLa9rYaB4G1mPTRhm+l/8=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=v${finalAttrs.version}"
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      version = "v${finalAttrs.version}";
    };

    help = runCommand "test-aperture-cli-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
      aperture --help 2>&1 | grep "print version and exit"
      touch $out
    '';
  };

  meta = {
    description = "Launch coding agents preconfigured against a Tailscale Aperture LLM gateway";
    homepage = "https://github.com/tailscale/aperture-cli";
    license = lib.licenses.bsd3;
    mainProgram = "aperture";
  };
})
