{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "imdb-plex-sync";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "imdb-plex-sync";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aL4/i2L+EnnPpOqw136prKRC7wSAYvwpCnzkdImFLGg=";
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
      command = "imdb-plex-sync -version";
      inherit (finalAttrs) version;
    };
  };

  meta = {
    description = "Sync IMDb watchlist to Plex watchlist";
    homepage = "https://github.com/josh/imdb-plex-sync";
    license = lib.licenses.mit;
    mainProgram = "imdb-plex-sync";
  };
})
