{
  mkDerivation,
  lib,
  fetchurl,
  licenceFile ? null,
  patchelf,
  fontconfig,
  libpng12,
  libICE,
  ncurses,
  libSM,
  libX11,
  libXau,
  libXext,
  libXpm,
  libXrender,
  zlib,
  makeWrapper,
  gcc,
  qtbase,
  qtscript,
  qtx11extras,
  qtxmlpatterns,
  libGLU,
  libGL,
}:
#assert licenceFile != null;
mkDerivation rec {
  pname = "arm-forge";
  version = "21.0";
  # https://developer.arm.com/tools-and-software/server-and-hpc/downloads/arm-forge
  src = fetchurl {
    url = "https://content.allinea.com/downloads/arm-forge-21.0-linux-x86_64.tar";
    sha256 = "sha256-cbcToF1DGjwmvYPMTQtloK/X1/W/V6oR7ftB2pDwF3Q=";
  };

  buildInputs = [
    patchelf
    makeWrapper
    qtbase
    fontconfig
    libpng12
    libICE
    ncurses
    libSM
    libX11
    libXau
    libXext
    libXpm
    libXrender
    zlib
  ];

  rPath = "${lib.makeLibraryPath [
    fontconfig
    libpng12
    libICE
    ncurses
    libSM
    libX11
    libXau
    libXext
    libXpm
    libXrender
    zlib
    qtbase
    qtscript
    qtx11extras
    qtxmlpatterns
    libGLU
    libGL
  ]}:${lib.getLib gcc.cc}/lib:/run/opengl-driver/lib";

  qtWrapperArgs = ["--suffix LD_LIBRARY_PATH : ${rPath}"];
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    tar xvf forge.tgz
    mkdir -p $out

    cp -r bin $out
    cp -r libexec $out

    for f in $out/bin/* $out/libexec/*; do
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath $(patchelf --print-rpath $f):$out/lib:${lib.getLib gcc.cc}/lib:${rPath}: \
      $f || true
    done
    for f in $out/lib/*; do
    patchelf \
      --set-rpath $(patchelf --print-rpath $f):$out/lib:${lib.getLib gcc.cc}/lib:${rPath}: \
      $f || true
    done
    #wrapProgram $out/libexec/forge.bin --prefix LD_LIBRARY_PATH : ${rPath}
    #wrapProgram $out/bin/ddt --prefix LD_LIBRARY_PATH : ${rPath}
    #wrapProgram $out/bin/forge --prefix LD_LIBRARY_PATH : ${rPath}
    # remove QT libraries provide by our Qt version
    rm lib/libQt*
    rm lib/libxcb*
    rm lib/libgcc*
    rm lib/libstdc++*
    rm lib/libGL*
    rm lib/libX*
    rm lib/libxkb*
    cp -r lib $out
    cp -r help $out
    cp -r doc $out

    cp -r icons $out
  '';

  meta = {
    homepage = "https://developer.arm.com/tools-and-software/server-and-hpc/debug-and-profile/arm-forge";
    decription = "leading server and HPC development tool suite for C, C++, Fortran, and Python high performance code on Linux";
    longDescription = ''
      Arm Forge includes Arm DDT, the best debugger for time-saving high performance application debugging, Arm MAP, the trusted performance profiler for invaluable optimization advice, and Arm Performance Reports to help you analyze your HPC application runs.
    '';
  };
}
