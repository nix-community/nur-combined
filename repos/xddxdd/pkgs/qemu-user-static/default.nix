{ stdenv
, lib
, sources
, ...
}:

let
  pname = "qemu-user-static";
  version = "6.2+dfsg-2";
  src =
    if stdenv.isx86_64 then sources.qemu-user-static-amd64.src
    else if stdenv.isAarch64 then sources.qemu-user-static-arm64.src
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
