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
  version = "latest-unstable-2026-10-27";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "git-pages";
    repo = "git-pages";
    rev = "ff707f2c2ccb8c34b4ca0fccb619476424f1cc75";
    hash = "sha256-sNl4DmlFwvHinKXkYWWWkbPELFCN2a9OhBFbrkx6P04=";
  };

  vendorHash = "sha256-Q6uFwlFP7p/Nh88Fever0QDG9/YXO3r6dkGcgKr+35E=";

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
