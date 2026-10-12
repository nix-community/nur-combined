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
  version = "latest-unstable-2026-10-11";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "git-pages";
    repo = "git-pages";
    rev = "cdfca73ecf85cabead53721ee07c1325ad886911";
    hash = "sha256-t8I3kaCKsTNz+gtPub5NbO6v15iEI56eIaWPc5mwtbY=";
  };

  vendorHash = "sha256-t70j1FJUrz9gIiSOLopFO+7wPvgU2QYEuUVSoNowQNc=";

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
