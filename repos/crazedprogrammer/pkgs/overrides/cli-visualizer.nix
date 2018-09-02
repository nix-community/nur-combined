{ stdenv, fetchFromGitHub, cli-visualizer, ... }:

cli-visualizer.overrideDerivation (old: rec {
  version = "1.7";
  name = "cli-visualizer-${version}";
  src = fetchFromGitHub {
    owner = "dpayne";
    repo = "cli-visualizer";
    rev = version;
    sha256 = "0mirp8bk398di5xyq95iprmdyvplfghxqmrfj7jdnpy554vx7ppc";
  };
})
