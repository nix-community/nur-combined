{ niri, fetchFromGitHub }:
let
  rev = "5a7453fa5d334cfc322852a55d39155f28be3204";
in
niri.overrideAttrs (
  final: old: {
    version = "26.04-unstable-2026-11-28";
    src = fetchFromGitHub {
      owner = "wrvsrx";
      repo = "niri";
      inherit rev;
      hash = "sha256-bZ//tAkA17Z88IeK9mpNWpJ8tySsLdvfK0yK0Dgvcks=";
    };
    cargoHash = "sha256-US27OLlBOyZcAK0SGH3VkFFp5BKjOui4RJHTrLBu9Us=";
    env = old.env // {
      NIRI_BUILD_COMMIT = rev;
      NIRI_BUILD_VERSION_STRING = "${final.version} (${rev})";
    };
    meta = old.meta // {
      changelog = "https://github.com/wrvsrx/niri/commits/${rev}/";
    };
  }
)
