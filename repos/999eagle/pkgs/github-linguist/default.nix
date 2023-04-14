{
  bundlerApp,
  ruby,
  cmake,
  pkg-config,
  bundlerUpdateScript,
}:
bundlerApp rec {
  pname = "github-linguist";
  exes = ["github-linguist"];

  inherit ruby;
  gemdir = ./.;

  nativeBuildInputs = [cmake pkg-config];

  passthru.updateScript = bundlerUpdateScript "github-linguist";
}
