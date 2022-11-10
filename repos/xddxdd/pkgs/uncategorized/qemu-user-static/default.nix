{ stdenv
, lib
, fetchurl
, ...
}:

let
  pname = "qemu-user-static";
  version = "7.0+dfsg-1";
  src =
    if stdenv.isx86_64 then
      fetchurl
        {
          url = "https://snapshot.debian.org/archive/debian/20220501T085721Z/pool/main/q/qemu/qemu-user-static_7.0+dfsg-1_amd64.deb";
          sha256 = "11y9wr4qn7rczpdv4mi3x9yhnfbnn969312n2qbv92s45ii4rql3";
        }
    else if stdenv.isAarch64 then
      fetchurl
        {
          url = "https://snapshot.debian.org/archive/debian/20220501T085721Z/pool/main/q/qemu/qemu-user-static_7.0+dfsg-1_arm64.deb";
          sha256 = "028mfrgvlyly95l8g6v16r3gcljgcmwvi2ing03164fh7rxcldkg";
        }
    else throw "Unsupported architecture";
in
stdenv.mkDerivation rec {
  inherit pname version src;

  phases = [ "installPhase" ];
  installPhase = ''
    ar x ${src}
    tar xf data.tar.xz
    mkdir -p $out
    cp -r usr/bin $out/bin
  '';

  meta = with lib; {
    homepage = "http://www.qemu.org/";
    description = "A generic and open source machine emulator and virtualizer";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
