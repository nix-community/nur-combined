{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "incusos-flasher";
  version = "202611192004-unstable-2026-11-19";

  src = fetchFromGitHub {
    owner = "lxc";
    repo = "incus-os";
    rev = "da768e7e255fd285b583f5740e1f41f355af5881";
    hash = "sha256-K5GgFaHgx0CUJ1iB0MbhLO3dOIxsMravZWsr4H38XcY=";
  };

  modRoot = "incus-osd";
  vendorHash = "sha256-dX/N+jac1y++XiDKZ/okqsAebn3a+NV0t/y1ApSXJfs=";
  subPackages = [ "cmd/flasher-tool" ];
  # INCUSOS_IMAGE_ARCHITECTURE selects images for a different target architecture.
  patches = [ ./image-architecture.patch ];
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  # The daemon's tests require host hardware and a running IncusOS system.
  doCheck = false;

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script {
      attrPath = finalAttrs.pname;
      extraArgs = [ "--version=branch=main" ];
    };
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
  };

  meta = {
    description = "Download and customize IncusOS installation images";
    homepage = "https://github.com/lxc/incus-os";
    license = lib.licenses.asl20;
    mainProgram = "flasher-tool";
    maintainers = [ lib.maintainers.yinfeng ];
    platforms = lib.platforms.linux;
    # Older nixpkgs (including our stable checks) cannot satisfy upstream go.mod.
    broken = lib.versionOlder go.version "1.26.9";
  };
})
