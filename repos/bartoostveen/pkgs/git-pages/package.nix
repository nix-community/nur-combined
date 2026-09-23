{
  lib,
  buildGoModule,
  fetchFromGitea,
  nix-update-script,
  testers,
  git-pages,
}:

# unstable version of what is already in nixpkgs, will remove once git-pages starts picking up proper releases again

buildGoModule (finalAttrs: {
  pname = "git-pages";
  version = "latest-unstable-2026-09-20";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "git-pages";
    repo = "git-pages";
    rev = "6c2f34c54d9084fd29935b8c43e59fec9af439b4";
    hash = "sha256-mvidsED90TDo4VcFe/exRSPf0j6WKvsu+7UZLB/evTU=";
  };

  vendorHash = "sha256-RKn3DxX/cJoR6cXkmR9UzwF9k67NZiGt9MKba178jBU=";

  ldflags = [
    "-s"
    "-X main.versionOverride=${
      if finalAttrs.src.tag == null then finalAttrs.src.rev else finalAttrs.src.tag
    }"
  ];

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version=branch=main" ]; };
    tests.version = testers.testVersion {
      package = git-pages;
      command = "git-pages -version";
      version = "git-pages ${
        if finalAttrs.src.tag == null then finalAttrs.src.rev else finalAttrs.src.tag
      }";
    };
  };

  meta = {
    description = "Scalable static site server for Git forges";
    homepage = "https://codeberg.org/git-pages/git-pages";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "git-pages";
  };
})
