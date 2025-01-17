{
  lib,
  buildGoModule,
  fetchFromGitHub,
  callPackage,
  tinyfeed,
  nix-update-script,
}:

let
  version = "1.0.1";
in

buildGoModule {
  pname = "tinyfeed";
  inherit version;

  src = fetchFromGitHub {
    owner = "TheBigRoomXXL";
    repo = "tinyfeed";
    rev = "refs/tags/v${version}";
    hash = "sha256-Fv58XshW+2l/kDW4UZt2+/GBHqtmpFH5OoQ2tccvLeg=";
  };

  vendorHash = "sha256-cDNGM1c/ZM5k3Er22Yw/IpCgij/NGwnk1OqKGhfGgY0=";

  ldflags = [
    "-s"
    "-w"
  ];

  passthru = {
    tests.tinyfeed = callPackage ./nixos-test.nix { inherit tinyfeed; };
    updateScript = nix-update-script { };
  };

  meta = {
    mainProgram = "tinyfeed";
    description = "Generate a static HTML page from a collection of feeds wtih a simple CLI tool";
    homepage = "https://github.com/TheBigRoomXXL/tinyfeed";
    changelog = "https://github.com/TheBigRoomXXL/tinyfeed/releases/tag/v${version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
