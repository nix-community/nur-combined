{
  lib,
  stdenvNoCC,
  fetchurl,
  update-feed,
}:

# feed-specific args
{ feedName, jsonPath, url }:

stdenvNoCC.mkDerivation {
  pname = feedName;
  version = "20230112";
  src = fetchurl {
    inherit url;
  };
  passthru.updateScript = [
    (lib.getExe update-feed) url jsonPath
  ];
  meta = {
    description = "metadata about any feeds available at ${feedName}";
    longDescription = ''
      this package isn't meant to actually be built;
      it exists to provide an `updateScript` for a given feed,
      so that feed metadata can be sync'd from the web into nix-native data structures.
    '';
    homepage = feedName;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.all;
  };
}

