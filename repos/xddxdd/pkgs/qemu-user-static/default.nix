{
  stdenv, lib, fetchurl,
  ...
}:

stdenv.mkDerivation rec {
  pname = "qemu-user-static";
  version = "6.1+dfsg-5";

  src = fetchurl {
    url = "http://ftp.us.debian.org/debian/pool/main/q/qemu/${pname}_${version}_amd64.deb";
    sha256 = "1jbz9qwnyvm0b3c5k8ps2x3bgqcx5rk894a0hxv0rhq82j3syf4r";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontPatchELF = true;

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
    platforms = platforms.unix;
    broken = !stdenv.hostPlatform.isx86_64;
  };
}
