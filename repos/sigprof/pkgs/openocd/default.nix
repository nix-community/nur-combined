{
  pkgs,
  fetchurl,
}:
pkgs.openocd.overrideAttrs (old: rec {
  pname = "openocd";
  version = "0.12.0-rc3";
  src = fetchurl {
    url = "mirror://sourceforge/project/${pname}/${pname}/${version}/${pname}-${version}.tar.bz2";
    sha256 = "464dc2d833158e5af8f1ce09606f6ed564b1de237485d9dd85dd4f156381cb78";
  };
  patches = [];
})
