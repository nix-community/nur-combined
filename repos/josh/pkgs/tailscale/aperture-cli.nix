{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "aperture-cli";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "aperture-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RxXEHd73j+Cef9GZk3pKjv7T3a60lGSi4vreKDW3JUU=";
  };

  vendorHash = "sha256-OEBKpEwaQ9ehSHDlkZjRoP2gRQByJK9Ikpe2nhIKzAg=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=v${finalAttrs.version}"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      version = "v${finalAttrs.version}";
    };

  };

  meta = {
    description = "Launch coding agents preconfigured against a Tailscale Aperture LLM gateway";
    homepage = "https://github.com/tailscale/aperture-cli";
    license = lib.licenses.bsd3;
    mainProgram = "aperture";
  };
})
