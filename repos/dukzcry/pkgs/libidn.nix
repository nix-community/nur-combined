{ libidn, fetchurl }:

libidn.overrideAttrs (oldAttrs: rec {
  pname = "libidn";
  version = "1.36";
  src = fetchurl {
    url = "mirror://gnu/libidn/${pname}-${version}.tar.gz";
    sha256 = "07pyy0afqikfq51z5kbzbj9ldbd12mri0zvx0mfv3ds6bc0g26pi";
  };
})
