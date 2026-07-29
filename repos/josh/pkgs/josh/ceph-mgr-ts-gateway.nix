{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "ceph-mgr-ts-gateway";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "ceph-mgr-ts-gateway";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h3cdemyYqITtzjwnm7Md6HlTl9EkBsldBvRcBIAc7Hc=";
  };

  vendorHash = "sha256-UpLPXWyA4aIDjlUNKgFh3hkres4QfUDHnB0hykeR7WA=";

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
    description = "Ceph Manager Tailscale Gateway";
    homepage = "https://github.com/josh/ceph-mgr-ts-gateway";
    license = lib.licenses.mit;
    mainProgram = "ceph-mgr-ts-gateway";
  };
})
