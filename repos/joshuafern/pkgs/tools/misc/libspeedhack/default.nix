{ multiStdenv, lib, fetchurl, writeShellScript }:

let
  libspeedhack_run = writeShellScript "libspeedhack" ''
    #!/bin/bash
    rm -f /tmp/speedhack_{pipe,log} # Remove old pipe and log
    mkfifo /tmp/speedhack_pipe # Create pipe for speed control commands
    export SHSPEED=1 # Set variable for scripting
    # Fix line below if you put libs in different location
    cd $(dirname "$0")
    LD_LIBRARY_PATH=../usr/lib/libspeedhack/lib32:../usr/lib/libspeedhack/lib64:$LD_LIBRARY_PATH \
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

  hardeningDisable = [ "format" ];

  enableParallelBuilding = true;

  installPhase = ''  
    install -dm755 "$out/usr/lib/"
    # Copy required files.
    mkdir -p $out/usr/lib/${name}
    cp -r ./{lib32,lib64} "$out/usr/lib/${name}"
    # Executable
    install -dm755 "$out/bin"
    cp -r ${libspeedhack_run} "$out/bin/${name}"
  '';

  meta = with multiStdenv.lib; {
    homepage = https://github.com/evg-zhabotinsky/libspeedhack;
    description = "A simple dynamic library to slowdown or speedup applications";
    platforms = platforms.unix;
    maintainers = with maintainers; [ joshuafern ];
    license = licenses.mit;
  };
}