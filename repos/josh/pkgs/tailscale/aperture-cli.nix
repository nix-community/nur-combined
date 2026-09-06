{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,

  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "aperture-cli";
  version = "0.0.10";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "aperture-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-E8sQWtpWI+1aDFvUHlJnwlh9FUPQ9sDdnmvVdC0R9Hs=";
  };

  vendorHash = "sha256-iM4z1fVNm9vSyyNcGf/rPCHJph6laiSos2AWwJJtOfU=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=v${finalAttrs.version}"
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  checkFlags = lib.lists.optionals stdenv.hostPlatform.isDarwin [
    "-skip=^TestSettings_InvalidJSONReturnsErrorWithoutReplacingFile$"
  ];

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
