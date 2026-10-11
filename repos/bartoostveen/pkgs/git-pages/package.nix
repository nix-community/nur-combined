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
  version = "latest-unstable-2026-10-10";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "git-pages";
    repo = "git-pages";
    rev = "c3036c5f04e2f67da52e21fa9c7151f3193ef8a1";
    hash = "sha256-XHu0Zw0+yxCrFHHAzwkBxvLgxzZ1mKQCeyUj+YjXjIE=";
  };

  vendorHash = "sha256-NOEJnNbOTVlWn23CJxORx3QVGUhNcsjCbrFp0v8Bs3Q=";

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
