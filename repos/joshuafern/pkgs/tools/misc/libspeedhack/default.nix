{ multiStdenv, lib, fetchurl, writeShellScript }:

let
  libspeedhack_run = writeShellScript "libspeedhack" ''
    #!/bin/sh
    rm -f /tmp/speedhack_{pipe,log} # Remove old pipe and log
    mkfifo /tmp/speedhack_pipe # Create pipe for speed control commands
    SCRIPT_PATH=$(dirname "$0") # Fix line below if you put libs in different location
    LD_LIBRARY_PATH=$SCRIPT_PATH/../usr/lib/libspeedhack/lib32:$SCRIPT_PATH/../usr/lib/libspeedhack/lib64:$LD_LIBRARY_PATH \
    LD_PRELOAD="libspeedhack.so:$LD_PRELOAD" \
    exec "$@"
  '';
in
multiStdenv.mkDerivation rec {
  name = "libspeedhack";

  src = fetchurl {
    url = "https://github.com/evg-zhabotinsky/libspeedhack/archive/master.tar.gz";
    sha256 = "0b9sc93h3h3n2c0lxqggi1p36h7i2maqmgmdrdw5v6gfmbln31pz";
  };

  installPhase = ''  
    install -dm755 "$out/usr/lib/"
    mkdir -p $out/usr/lib/${name}
    cp -r ./{lib32,lib64} "$out/usr/lib/${name}"
    install -dm755 "$out/bin"
    cp -r ${libspeedhack_run} "$out/bin/${name}"
  '';

  meta = with multiStdenv.lib; {
    homepage = https://github.com/evg-zhabotinsky/libspeedhack;
    description = "A simple dynamic library to slow down or speed up applications";
    platforms = platforms.linux;
    maintainers = with maintainers; [ joshuafern ];
    license = licenses.mit;
  };
}