{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name =  "bacnet-stack-${version}";
  version = "0.8.6";
  

  src = fetchFromGitHub {
    owner = "bacnet-stack";
    repo = "bacnet-stack";
    rev = "3f42838a054e5fc7cb95938c3064a54e65569dbb";
    sha256 = "sha256-cH1YXz8KP8k5BY6dmD1Mu1KdsTF31UiMGLPjWhRHosM=";
  };
 
  patches = [ ./bacnet-stack-0.8.6.patch ]; 


  installPhase = ''
    mkdir -p $out/bin $out/lib 
    cp bin/ba* bin/bv* $out/bin
    cp lib/libbacnet.a /lib
    cp -r include $out/
  '';
  
  meta = with lib; {
    homepage = "http://bacnet.sourceforge.net";
    description = "BACnet Protocol Stack library provides a BACnet application layer, network layer and media access (MAC) layer communications services.";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
