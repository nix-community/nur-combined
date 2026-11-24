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
  version = "202611232003-unstable-2026-11-24";

  src = fetchFromGitHub {
    owner = "lxc";
    repo = "incus-os";
    rev = "7629b1278361ab80298d3ec823334a25a95c1c64";
    hash = "sha256-7Kgl4HU3+TO+ac+rQkRa4/BSpvMMu3Nm/+E5WmUUAjM=";
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
