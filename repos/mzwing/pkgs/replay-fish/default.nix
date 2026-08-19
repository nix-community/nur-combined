{
  lib,
  fishPlugins,
  source,
}:
fishPlugins.buildFishPlugin {
  inherit (source) pname src;
  # Version the tracked HEAD commit as unstable.
  version = "0-unstable-${source.date}";

  meta = {
    description = "Run Bash commands, replay changes in Fish";
    homepage = "https://github.com/jorgebucaran/replay.fish";
    license = lib.licenses.mit;
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = lib.platforms.all;
  };
}
