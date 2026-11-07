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
  version = "202611072003-unstable-2026-11-07";

  src = fetchFromGitHub {
    owner = "lxc";
    repo = "incus-os";
    rev = "31d11d31b512681243e3f1f585113275a0d8160a";
    hash = "sha256-CS8tQVPlhrZK0VH05x4Tk8/8h+bloLO/EzpOG/PCfuY=";
  };

  modRoot = "incus-osd";
  vendorHash = "sha256-ReweuhSSEmpGyIpyqP9aZglZ7f3R+fjK1BprTNsVLXw=";
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
