{
  lib,
  buildFishPlugin,
  fetchFromGitHub,
}:
buildFishPlugin {
  pname = "fzfish";
  version = "unstable-2026-03-16";

  src = fetchFromGitHub {
    owner = "adam01110";
    repo = "FzFish";
    rev = "bcf4dae827866ba6f6c4c2a27163acf7989a6e9b";
    hash = "sha256-ttwgJ3FxZulYFhAiq4We06AHXWmkYgvc8aZUlE3y1b8=";
  };

  meta = {
    description = "Fzf-powered fish completions with customizable completion rules";
    homepage = "https://github.com/adam01110/FzFish";
    license = lib.licenses.mit;
  };
}
