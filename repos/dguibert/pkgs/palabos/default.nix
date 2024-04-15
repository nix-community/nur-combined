{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  name = "palabos-v2.0r0";

  src = fetchurl {
    url = "http://www.palabos.org/images/palabos_releases/palabos-v2.0r0.tgz";
    sha256 = "1gjimsa7bq7cbba8r6q57icwwnjv0qhx186vm8ndqb0832fnb3bi";
  };
  passthru = {
    inherit src;
  };
  meta = {
    homepage = "http://www.palabos.org";
    broken = true;
  };
}
