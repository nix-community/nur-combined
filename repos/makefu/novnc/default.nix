{ stdenv, fetchurl, pkgs }:
# source: https://github.com/hyphon81/Nixtack/blob/master/noVNC/noVNC.nix
let
in

stdenv.mkDerivation rec {
  name = "novnc-${version}";
  version = "0.6.2";

  src = fetchurl {
    url = "https://github.com/novnc/noVNC/archive/v${version}.tar.gz";
    sha256 = "16ygbdzdmnfg9a26d9il4a6fr16qmq0ix9imfbpzl0drfbj7z8kh";
  };
  p = stdenv.lib.makeBinPath [ pkgs.nettools pkgs.python27Packages.websockify
                               pkgs.coreutils pkgs.which pkgs.procps ];
  patchPhase = ''
    sed -i '1aset -efu\nexport PATH=${p}\n' utils/launch.sh
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp utils/launch.sh $out/bin/launch-novnc.sh
    chmod +x $out/bin/launch-novnc.sh
    mkdir -p $out/images
    cp -r images/* $out/images/
    mkdir -p $out/include
    cp -r include/* $out/include/
    cp favicon.ico $out
    cp vnc.html $out
    cp vnc_auto.html $out
  '';

  meta = with stdenv.lib; {
    homepage = http://novnc.com/info.html;
    repositories.git = git://github.com/novnc/noVNC.git;
    description = ''
      A HTML5 VNC Client
    '';
    license = licenses.mpl20;
  };
}
