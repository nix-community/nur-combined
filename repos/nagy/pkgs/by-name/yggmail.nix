{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule {
  pname = "yggmail";
  version = "0-unstable-2026-10-24";

  src = fetchFromGitHub {
    owner = "neilalexander";
    repo = "yggmail";
    rev = "6973c70228a870b9cf8281af785085a85ca0322a";
    hash = "sha256-xDVex5AFw8v69uVLB6ZUosSOqTRjiCDvNNNJj+49Z+A=";
  };

  vendorHash = "sha256-5Iy95KzTCdXfAL2uEFB0F957/Svk7RwWTZbgSi2RoHg=";

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "End-to-end encrypted email for the mesh networking age";
    homepage = "https://github.com/neilalexander/yggmail";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "yggmail";
  };
}
