{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name =  "bacnet-stack-${version}";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "bacnet-stack";
    repo = "bacnet-stack";
# 1.0.0
    #rev = "cfb82a937fe64b9c7d8eae1f7e723879bb4c9305";
    #sha256 = "sha256-cCPkdHllUfwFjFJh313trmP5rjiZPf7voc7s5DU+Fx0=";
# 0.8.6
    rev = "3f42838a054e5fc7cb95938c3064a54e65569dbb";
    sha256 = "sha256-cH1YXz8KP8k5BY6dmD1Mu1KdsTF31UiMGLPjWhRHosM=";
  };

  patches = [ ./bacnet-stack-0.8.6.patch ];

  #preBuild = ''
  #	substituteInPlace include/bip.h --replace "net.h" "bvlc.h"
  #'';

  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp bin/ba* bin/bv* $out/bin
    cp lib/libbacnet.a $out/lib
    cp -r include $out/
    cp -r ports $out/include
  '';

  meta = with lib; {
    homepage = "http://bacnet.sourceforge.net";
    description = "BACnet Protocol Stack library provides a BACnet application layer, network layer and media access (MAC) layer communications services.";
    license = licenses.asl20;
    platforms = platforms.linux;
    broken = true;
  };
}
