{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "quien";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "retlehs";
    repo = "quien";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HTTogbcBa/dOIZAl1sNCqZODlFk50N+94jDxQrWQwb8=";
  };

  vendorHash = "sha256-7gP6eN+lF90kSltQMHkVTTanogEAtbLnENdZTF9f98c=";

  # v0.12.0 was tagged with a Go patch release newer than nixpkgs' current
  # toolchain. It does not rely on patch-release-specific language features.
  postPatch = ''
    substituteInPlace go.mod --replace-fail "go 1.26.4" "go 1.26.2"
  '';

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Whois and domain intelligence toolkit";
    homepage = "https://github.com/retlehs/quien";
    changelog = "https://github.com/retlehs/quien/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "quien";
    platforms = lib.platforms.all;
  };
})
