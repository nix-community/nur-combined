{
  fetchurl,
  fetchpatch,
  socat,
}:

socat.overrideAttrs rec {
  pname = "socat-patched";
  version = "1.8.0.0";

  src = fetchurl {
    url = "http://www.dest-unreach.org/socat/download/socat-${version}.tar.bz2";
    hash = "sha256-4d5oPdIu4OOmxrv/Jpq+GKsMnX62UCBPElFVuQBfrKc=";
  };

  patches = [
    # https://github.com/termux/termux-packages/issues/18645#issuecomment-1872909356
    (fetchpatch {
      url = "https://github.com/termux/termux-packages/raw/bootstrap-2024.06.23-r1%2Bapt-android-7/packages/socat/0004-udp-listen-bind4.patch";
      hash = "sha256-EfpcXGd4ed+rStLSlU2LYi02y1+lVnvESE4+JhawseA=";
    })
  ];

}
