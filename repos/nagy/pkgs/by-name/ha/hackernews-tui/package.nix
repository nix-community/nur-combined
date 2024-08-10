{
  lib,
  fetchFromGitHub,
  rustPlatform,
  testers,
  callPackage,
}:

rustPlatform.buildRustPackage rec {
  pname = "hackernews-tui";
  version = "0.13.4";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-xmqvR1u4owgrZSEmR81I418MHCwn4Ydp9+O6ijEEJ3A=";
  };

  cargoHash = "sha256-1lNBKWUM4MclZVJi9fT4as9ayamlzcrfeUX6P4nYxag=";

  passthru.tests.version = testers.testVersion {
    package =
      # a substitute for `finalAttrs.package`
      (callPackage ./package.nix { });
  };

  meta = with lib; {
    description = "Terminal UI to browse Hacker News";
    homepage = "https://github.com/aome510/hackernews-TUI";
    license = with licenses; [ mit ];
    mainProgram = "hackernews_tui";
  };
}
