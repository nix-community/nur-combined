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
  version = "latest-unstable-2026-07-30";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "git-pages";
    repo = "git-pages";
    rev = "472ae7ecaf0a31395952dc7bade2acb7efa5254c";
    hash = "sha256-6ph7+yRQQ98Li9n5w0X3F+03YI9ipkcQhmmmAaeLunE=";
  };

  vendorHash = "sha256-CmWI0cR31N8zPXyU95XDs/43ayFa6G5KCHf/+iC0oxc=";

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
