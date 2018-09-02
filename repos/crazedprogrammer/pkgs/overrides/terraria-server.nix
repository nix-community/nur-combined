{ terraria-server, fetchurl, lib, ... }:

terraria-server.overrideAttrs (old: rec {
  name = "terraria-server-${version}";
  version = "1.3.5.3";

  src = fetchurl {
    url = "http://terraria.org/server/terraria-server-${lib.replaceChars ["."] [""] version}.zip";
    sha256 = "0l7j2n6ip4hxph7dfal7kzdm3dqnm1wba6zc94gafkh97wr35ck3";
  };
})
