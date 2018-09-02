{ stdenv, fetchFromGitHub, SDL2, libGL, libGLU, luajit, cmake, curl }:

let
  sdl_gpu = stdenv.mkDerivation rec {
    name = "sdl_gpu-${version}";
    version = "2018-07-26";
    src = fetchFromGitHub {
      owner = "grimfang4";
      repo = "sdl-gpu";
      rev = "dd982b9c7af9f9f7c8806d20cf29ff348f8ab937";
      sha256 = "0xs72r26r4z8k2fxmk0na75zqr5z7a3mx1hsaz0qw81fpq3ad70j";
    };
    buildInputs = [ SDL2 libGL cmake libGLU ];
    enableParallelBuilding = true;
  };
  libcurlpp = stdenv.mkDerivation rec {
    name = "libcurlpp-${version}";
    version = "2018-06-15";
    src = fetchFromGitHub {
      owner = "jpbarrette";
      repo = "curlpp";
      rev = "8810334c830faa3b38bcd94f5b1ab695a4f05eb9";
      sha256 = "11yrsjcxdcana5pwx5sqc9k2gwr3v1li9bapc940cj83mg8fw0iy";
    };
    buildInputs = [ curl cmake ];
    enableParallelBuilding = true;
  };
in

stdenv.mkDerivation rec {
  name = "riko4-${version}";
  version = "2018-08-05";
  src = fetchFromGitHub {
    owner = "incinirate";
    repo = "Riko4";
    rev = "c93f018b8342120b24a6d94e7ea9dfc97f7c7356";
    sha256 = "09nfdvgrvdbr1139hi6s0ra4ffa5xgikrzrh7hlm2nilncws4xia";
  };

  buildInputs = [ SDL2 luajit cmake curl sdl_gpu libcurlpp ];
  hardeningDisable = [ "fortify" ];

  cmakeFlags = [ "-DSDL2_gpu_INCLUDE_DIR=\"${sdl_gpu}/include\"" ];
  makeFlags = [ "CXX_FLAGS+=-g" ];
  dontStrip = true;

  installPhase = ''
    install -Dm0755 riko4 $out/bin/.riko4-unwrapped
    mkdir -p $out/lib/riko4
    cp -r ../data $out/lib/riko4
    cp -r ../scripts $out/lib/riko4
    cat > $out/bin/riko4 <<EOF
    #!/bin/sh
    pushd $out/lib/riko4 > /dev/null
    ../../bin/.riko4-unwrapped
    popd > /dev/null
    EOF
    chmod +x $out/bin/riko4
  '';
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Fantasy console for pixel art game development";
    license = licenses.mit;
  };
}
