{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "gh-pr-reviews";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = "gh-pr-reviews";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hqVywLYKbchEKIPtTV8JelDhVcYo06Dd1FpJD5bA0T0=";
  };

  vendorHash = "sha256-yRnFLiGbCysDT91Zuse6DbuwTkMQOKXCsBNeG+XDyIY=";

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
