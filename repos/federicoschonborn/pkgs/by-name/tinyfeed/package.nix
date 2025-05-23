{
  lib,
  buildGoModule,
  fetchFromGitHub,
  callPackage,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "tinyfeed";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "TheBigRoomXXL";
    repo = "tinyfeed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Y0YgvouUz/hCeLriHR+SKze1+DSxVV74xfMFdEhe/r0=";
  };

  vendorHash = "sha256-lwT2eD+zFI49wvdlLcZILa2X/NsEi/jDzshngH3CLyQ=";

  ldflags = [
    "-s"
    "-w"
  ];

  passthru = {
    tests.tinyfeed = callPackage ./nixos-test.nix { tinyfeed = finalAttrs.finalPackage; };
    updateScript = nix-update-script { extraArgs = [ "--version-regex=v(.*)" ]; };
  };

  meta = {
    mainProgram = "tinyfeed";
    description = "Generate a static HTML page from a collection of feeds with a simple CLI tool";
    homepage = "https://github.com/TheBigRoomXXL/tinyfeed";
    changelog = "https://github.com/TheBigRoomXXL/tinyfeed/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
