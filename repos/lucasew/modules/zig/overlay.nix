self: super:
let 
  zlsSrc = super.pkgs.fetchgit {
    url = "https://github.com/zigtools/zls";
    rev = "72f811e8dc2c28165fbbc28e5efbb4f3616ffa67";
    sha256 = "0fij7zxf67sdxm2x01x9v7rxl3gd8y026g2fh257w744b0xr0llx";
    fetchSubmodules = true;
  };
in {
  # zls = import "${zlsSrc}" {zig = super.zig;};
  zls = import zlsSrc {};
}
