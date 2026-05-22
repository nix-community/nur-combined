{ vimUtils, source }:
vimUtils.buildVimPlugin {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;
}
