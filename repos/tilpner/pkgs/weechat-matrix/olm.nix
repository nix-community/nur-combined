{ olm, fetchurl }:

olm.overrideAttrs (old: rec {
  name = "olm-${version}";
  version = "3.1.3";

  # Temporarily different URL, matrix.org seems to have not yet gotten around to setting up
  # the old URLs after the security breach
  src = fetchurl {
    url = "https://gitlab.matrix.org/matrix-org/olm/-/archive/${version}/${name}.tar.gz";
    sha256 = "1zr6bi9kk1410mbawyvsbl1bnzw86wzwmgc7i5ap6i9l96mb1zqh";
  };
})
