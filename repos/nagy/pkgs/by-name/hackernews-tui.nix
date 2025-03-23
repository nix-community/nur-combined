{
  lib,
  fetchFromGitHub,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hackernews-tui";
  version = "0.13.5";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = "hackernews-tui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-p2MhVM+dbNiWlhvlSKdwXE37dKEaE2JCmT1Ari3b0WI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-KuqAyuU/LOFwvvfplHqq56Df4Dkr5PkUK1Fgeaq1REs=";

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Terminal UI to browse Hacker News";
    homepage = "https://github.com/aome510/hackernews-TUI";
    license = with lib.licenses; [ mit ];
    mainProgram = "hackernews_tui";
  };
})
