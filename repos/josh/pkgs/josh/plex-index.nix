{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "plex-index";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "plex-index";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bw2/ZNPC6LiHUBBHWzIViKQQlX1Nl6nk1tFMQ+DgV40=";
  };

  vendorHash = "sha256-9FLAVUGHmokTj6nZzo65wdVzaa9t/5MUMVnyC+Lt5LI=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      command = "plex-index -version";
      inherit (finalAttrs) version;
    };
  };

  meta = {
    description = "Index of Plex rating keys mapped to IMDb, TMDb and TVDb IDs";
    homepage = "https://github.com/josh/plex-index";
    license = lib.licenses.mit;
    mainProgram = "plex-index";
  };
})
