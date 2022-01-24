{ stdenv
, lib
, fetchurl
, ...
}:

let
  pname = "qemu-user-static";
  version = "6.2+dfsg-2";
  src = if stdenv.isx86_64 then fetchurl {
    url = "http://ftp.us.debian.org/debian/pool/main/q/qemu/${pname}_${version}_amd64.deb";
    sha256 = "1n88mszvj65478b75105i3i6yy0ipdsgnlkm72nqn8gxaj978ghd";
  } else if stdenv.isAarch64 then fetchurl {
    url = "http://ftp.us.debian.org/debian/pool/main/q/qemu/${pname}_${version}_arm64.deb";
    sha256 = "04wgzhcc4n0rw9rd2czxl8a00gn89fcc89q79sm5nvb134jnd1jp";
  } else throw "Unsupported architecture";
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
