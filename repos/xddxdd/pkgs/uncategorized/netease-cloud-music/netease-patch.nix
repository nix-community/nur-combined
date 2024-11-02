{
  stdenv,
  fetchurl,
  # Dependencies
  libvlc,
}:
# Source: https://aur.archlinux.org/packages/netease-cloud-music
stdenv.mkDerivation {
  pname = "netease-cloud-music-patch";
  version = "1.0";
  src = fetchurl {
    url = "https://aur.archlinux.org/cgit/aur.git/plain/patch.c?h=netease-cloud-music";
    sha256 = "02di6s1c8h2s5501fl69prspfwqmqzahvy4q8m31cdxxgkgfv00h";
  };

  dontUnpack = true;

  buildPhase = ''
    cp $src libnetease-patch.c
    cc -O2 -fPIC -shared \
      -I ${libvlc}/include/ \
      -I ${libvlc}/include/vlc/plugins/ \
      -o libnetease-patch.so \
      libnetease-patch.c
  '';

  installPhase = ''
    install -Dm755 libnetease-patch.so $out/lib/libnetease-patch.so
  '';
}
