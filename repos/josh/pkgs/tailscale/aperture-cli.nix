{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  go,
  nix-update-script,
  testers,
}:
assert lib.assertMsg (lib.versionOlder go.version "1.26.10")
  "aperture-cli: stock go ${go.version} now satisfies go.mod, switch back to buildGoModule";
buildGo127Module (finalAttrs: {
  pname = "aperture-cli";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "aperture-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WO2+KR/3aRvPvBtlyQNDC3b0emIApnMASCWESlXGkc4=";
  };

  vendorHash = "sha256-1JGF7ngvUz/YDKYp3cA06fKE0ZlmVI3Y7pBzhkQ/MJQ=";

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
