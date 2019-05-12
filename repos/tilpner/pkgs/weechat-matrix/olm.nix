{ olm, fetchurl }:

olm.overrideAttrs (old: rec {
  name = "olm-${version}";
  version = "3.1.2";

  # Temporarily different URL, matrix.org seems to have not yet gotten around to setting up
  # the old URLs after the security breach
  src = fetchurl {
    url = "https://gitlab.matrix.org/matrix-org/olm/-/archive/${version}/${name}.tar.gz";
    sha256 = "0qa0n7hl6cgrjx6yy3idllzmvyh7gm5vgkm5jbyhlcr33rhjxd4n";
  };
})
