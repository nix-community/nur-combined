{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "ceph-mgr-ts-gateway";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "ceph-mgr-ts-gateway";
    tag = "v${finalAttrs.version}";
    hash = "sha256-db3xPthQUDLYloLRWMtqdCpheI05jxMk5v9dV68nvco=";
  };

  vendorHash = "sha256-V6GgjNyEhsw3ISOrFh58GFkN7jNB0fQQ6+6fNfpe3Dk=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    help =
      runCommand "test-ceph-mgr-ts-gateway-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          ceph-mgr-ts-gateway --help
          touch $out
        '';
  };

  meta = {
    description = "Tailscale gateway to Ceph manager service endpoints";
    homepage = "https://github.com/josh/ceph-mgr-ts-gateway";
    license = lib.licenses.mit;
    mainProgram = "ceph-mgr-ts-gateway";
    broken = lib.strings.versionOlder go.version "1.26.5";
  };
})
