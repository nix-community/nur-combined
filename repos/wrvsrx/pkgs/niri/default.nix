{ niri, fetchgit }:
let
  rev = "5a7453fa5d334cfc322852a55d39155f28be3204";
in
niri.overrideAttrs (old: {
  src = fetchgit {
    url = "https://github.com/wrvsrx/niri.git";
    inherit rev;
    fetchSubmodules = false;
    hash = "sha256-bZ//tAkA17Z88IeK9mpNWpJ8tySsLdvfK0yK0Dgvcks=";
  };
  cargoHash = "sha256-US27OLlBOyZcAK0SGH3VkFFp5BKjOui4RJHTrLBu9Us=";
  env = old.env // {
    NIRI_BUILD_COMMIT = rev;
  };
})
