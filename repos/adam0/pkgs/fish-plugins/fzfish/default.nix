{
  # keep-sorted start
  buildFishPlugin,
  fetchFromGitHub,
  lib,
  # keep-sorted end
}:
buildFishPlugin {
  pname = "fzfish";
  version = "0-unstable-2026-03-24";

  src = fetchFromGitHub {
    owner = "adam01110";
    repo = "FzFish";
    rev = "b1364e5bc434a71e93076a4a7a833e2f0546f5a0";
    hash = "sha256-CZq3vqvjcFuxhttgEtumfsFIZY9kfOVDhMUQLZIimQ8=";
  };

  meta = {
    # keep-sorted start
    description = "Configurable fzf completions for fish shell";
    homepage = "https://github.com/adam01110/FzFish";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
