{ stdenv, fetchurl, upx, zlib, libGL, libGLU, SDL, SDL_mixer, freeglut, xorg }:

let

  rpath = stdenv.lib.makeLibraryPath [
    stdenv.cc.cc
    zlib
    libGL
    libGLU
    SDL
    SDL_mixer
    freeglut
    xorg.libXcursor
  ];

  binary = if stdenv.isi686 then "giana_linux32" else "giana_linux64";

in

stdenv.mkDerivation rec {
  name = "gianas-return-${version}";
  version = "1.10";

  src = fetchurl {
    url = "http://www.retroguru.com/gianas-return/gianas-return-v.latest-linux.tar.gz";
    sha256 = "0y0g8brlg26yg072m1rb8vhnbif1i19cfgw1vqzqlxc90q31ndgh";
  };

  buildInputs = [ upx ];
  buildCommand = ''
    unpackPhase
    cd $sourceRoot
    patchPhase

    # https://github.com/NixOS/patchelf/issues/63
    upx -d ./${binary}
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" ${binary}
    patchelf --set-rpath ${rpath} ${binary}

    mkdir -p $out/share/gianas-return
    cp -r * $out/share/gianas-return

    mkdir $out/bin
    cat >$out/bin/${binary} << EOF
      #! ${stdenv.shell}

      cd $out/share/gianas-return
      ./${binary}
    EOF

    chmod +x $out/bin/${binary}
  '';

  meta = with stdenv.lib; {
    description = "Giana’s Return aims to be a worthy UNOFFICIAL sequel of 'The Great Giana Sisters'.";
    homepage = http://www.gianas-return.de/;
    license = licenses.unfree; # only a binary is available ATM
    platforms = platforms.linux;
    maintainers = with maintainers; [ ma27 ];
  };
}
