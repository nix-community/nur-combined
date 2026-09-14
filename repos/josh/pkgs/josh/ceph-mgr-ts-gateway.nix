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
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "ceph-mgr-ts-gateway";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EWXbR8lJB7JZdLaSzoxcfIN2JjCm/UkKz5hA+yqZIlE=";
  };

  vendorHash = "sha256-o/dPtpCvgcqIOfymODVWJiNfTVcjjD9lmQH56gx611E=";

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
