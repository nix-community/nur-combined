{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "gh-pr-reviews";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = "gh-pr-reviews";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WiD22SJ4/H3sY+f7W1H3L1mHHru8G0Qurf4g40kVW4g=";
  };

  vendorHash = "sha256-XspIjeDNoHuJ+9tdn7/aqVJZHCdzdbMyIH0j4lbz2i0=";

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
