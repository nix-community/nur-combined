{ fetchFromGitHub }:

rec {
  version = "3.24.0";
  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "nix-src";
    tag = "v${version}";
    hash = "sha256-wBbomknnynmW74SjD4xRgpymGxJx96aUtYr3Dnyi4/Y=";
  };
}
