{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "ceph-mgr-ts-gateway";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "ceph-mgr-ts-gateway";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0LqaRYRWEe3ODjUDjltvUK2T82saYFqmSnmDLhoTIm8=";
  };

  vendorHash = "sha256-qd2jc5Tyw56/o1t8H2Bi3vqTRvjOUcSbOyUtt3Rz8bk=";

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
  };
})
