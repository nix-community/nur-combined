{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "gh-pr-reviews";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = "gh-pr-reviews";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sqqmnYLYhXkEPOHht+mlJS9AWAHXCUWnVt1KBOvvZDM=";
  };

  vendorHash = "sha256-B3Yr+IYCDdX5pJtwHdy4O8ut4QNTXgy5wmMdxGf7RpE=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "GitHub CLI extension to identify unresolved review comments in a pull request";
    homepage = "https://github.com/k1LoW/gh-pr-reviews";
    changelog = "https://github.com/k1LoW/gh-pr-reviews/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "gh-pr-reviews";
  };
})
