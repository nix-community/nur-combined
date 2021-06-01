{ stdenv, lib, requireFile, makeWrapper, writeScriptBin, bash, perl, tcl-8_5, tk-8_5
, netcdf, libGLU, xorg, fltk, vrpn, flex, bison, libGL_driver, cudatoolkit, autoPatchelfHook
}:
assert
  lib.asserts.assertMsg
  (stdenv.isLinux && stdenv.isx86_64)
  "The VMD binaries require an x86_64 linux OS with CUDA support.";

let homepage = "https://www.ks.uiuc.edu/Research/vmd/";

in stdenv.mkDerivation rec {
  pname = "vmd";
  version = "1.9.3";

  src = requireFile {
    url = homepage;
    name = "vmd-1.9.3.bin.LINUXAMD64-CUDA8-OptiX4-OSPRay111p1.opengl.tar.gz";
    sha256 = "9427a7acb1c7809525f70f635bceeb7eff8e7574e7e3565d6f71f3d6ce405a71";
  };

  nativeBuildInputs = [
    perl
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    libGLU
    xorg.libX11
    xorg.libXinerama
    xorg.libXi
    tcl-8_5
    tk-8_5
    netcdf
    fltk
    vrpn
    flex
    bison
    libGL_driver
    cudatoolkit.out
    cudatoolkit.lib
    # nvidia_x11
  ];

  postPatch = ''
    substituteInPlace ./configure \
      --replace '/usr/local' "$out" \
      --replace '-ll' '-lfl'

    patchShebangs ./configure
  '';

  sourceRoot = "vmd-${version}";

  # non-standard configure script
  configurePhase = ''
    ./configure
  '';

  dontBuild = true;

  preInstall = ''
    cd src
  '';

  postInstall = ''
    # Needs libcuda.so.1 but only finds libcuda.so
    ln -s ${cudatoolkit}/targets/x86_64-linux/lib/stubs/libcuda.so $out/lib/libcuda.so.1

    # Makes tachyon available
    ln -s $out/lib/vmd/{stride,surf,tachyon}_LINUXAMD64 $out/bin/.
  '';

  # libnvcuvid.so depends on the linuxPackages.nvidia_x11.
  # This might be overriden in configuration.nix and should be detected at runtime at
  # /var/run/opengl-driver/lib
  autoPatchelfIgnoreMissingDeps = true;

  postFixup = ''
    wrapProgram $out/bin/vmd \
      --set "LC_ALL" "C"
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    inherit homepage;
    description = "Molecular dynamics visualisation program";
    license = licenses.unfree;
    maintainers = [ maintainers.sheepforce ];
    platforms = [ "x86_64-linux" ];
  };
}
