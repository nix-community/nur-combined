{
  lib,
  fishPlugins,
  source,
}:
fishPlugins.buildFishPlugin {
  inherit (source) pname src;
  # nvfetcher tracks the upstream HEAD commit; use the nixpkgs
  # unstable-version convention (same as hfd).
  version = "0-unstable-${source.date}";

  meta = {
    description = "Parse CLI options in Fish";
    homepage = "https://github.com/jorgebucaran/getopts.fish";
    license = lib.licenses.mit;
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = lib.platforms.all;
  };
}
