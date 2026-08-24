{
  fetchzip,
  lib,
  luaPackages,
  writeScript,
  breakpointHook,
}:
let
  version = "5.2.3";
in
luaPackages.buildLuarocksPackage {
  pname = "lua-resty-mpd";
  inherit version;
  src = fetchzip {
    url = "https://buffering.party/software/lua-resty-mpd/lua-resty-mpd-${version}.tar.gz";
    sha256 = "sha256-myGOgzqQOCWzL6bwqzRhfReRPdHrFKTb89H/bRmIZD8=";
  };

  nativeBuildInputs = [breakpointHook];

  knownRockspec = "specs/lua-resty-mpd-${version}-0.rockspec";

  passthru.updateScript = writeScript "update-lua-resty-mpd" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl pcre2 common-updater-scripts

    version="$(curl -s https://buffering.party/software/lua-resty-mpd/index.atom \
      | pcre2grep -o1 'lua-resty-mpd-(\d+\.\d+\.\d+).tar.gz' \
      | head -1)"
    update-source-version "$UPDATE_NIX_ATTR_PATH" "$version"
  '';

  meta = {
    description = "Client library for the Music Player Daemon, compatible with OpenResty, cqueues, and Luasocket";
    homepage = "https://buffering.party/software/lua-resty-mpd/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
