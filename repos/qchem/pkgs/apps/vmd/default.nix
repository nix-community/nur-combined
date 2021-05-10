{ lib, stdenv, requireFile, perl, tcl-8_5, tk-8_5, netcdf
, libGL_driver, libGLU, xorg, fltk, vrpn, flex, bison
} :

let
  version = "1.9.3";
  homepage = "https://www.ks.uiuc.edu/Research/vmd/";

  plugins = stdenv.mkDerivation {
    pname = "vmd-plugins";
    inherit version;

    src = requireFile {
      url = homepage;
      name = "vmd-${version}.src.tar.gz";
      sha256 = "0a7ijps3qmp2qkz0ys31bd96dkz3vg1vdm0fa7z21minr16k3p2v";
    };

    #nativeBuildInputs = [ perl ];
    buildInputs = [ tcl-8_5 netcdf ];

    postPatch = ''
    '';

    sourceRoot = "plugins";

    makeFlags = [ "LINUXAMD64" ];

    preBuild = ''
      export PLUGINDIR=$out/
    '';

    installTargets = "distrib";

    enableParallelBuilding = false;

    meta = with lib; {
      inherit homepage;
      description = "Molecular dyanmics visualisation program";
      license = licenses.unfree;
      maintainers = [ maintainers.markuskowa ];
      platforms = platforms.linux;
    };
  };

in stdenv.mkDerivation {
  pname = "vmd";
  inherit version;

  src = requireFile {
    url = homepage;
    name = "vmd-${version}.src.tar.gz";
    sha256 = "0a7ijps3qmp2qkz0ys31bd96dkz3vg1vdm0fa7z21minr16k3p2v";
  };

  nativeBuildInputs = [ perl ];
  buildInputs = [
    plugins libGL_driver libGLU xorg.libX11
    xorg.libXinerama xorg.libXi tcl-8_5 tk-8_5 netcdf
    fltk vrpn flex bison
  ];

  postPatch = ''
    ln -s ${plugins} plugins
    substituteInPlace ./configure \
                      --replace '/usr/local' "$out" \
                      --replace '-ll' '-lfl'

  '';

  sourceRoot = "vmd-${version}";


  # non-standard configure script
  configurePhase = ''
    patchShebangs ./configure
    ./configure LINUXAMD64 OPENGL OPENGLPBUFFER FLTK TK \
                IMD XINERAMA XINPUT \
                VRPN NETCDF COLVARS TCL \
                PTHREADS SILENT GCC
  '';

  preBuild = ''
    #make linux.amd64.opengl
    cd src
  '';

  enableParallelBuilding = true;


  meta = with lib; {
    inherit homepage;
    description = "Molecular dynamics visualisation program";
    license = licenses.unfree;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}
