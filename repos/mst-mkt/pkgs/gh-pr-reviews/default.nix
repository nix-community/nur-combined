{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "gh-pr-reviews";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = "gh-pr-reviews";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GsBbbrvuYjlSnb5JQOTMtNQnxGrrQpcahEDMUQaJEeY=";
  };

  vendorHash = "sha256-vHJlCFpR+uc+jrHyXGZOjOpP0r0n15UhV7XQQyAa9pA=";

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
