{ stdenv
, openssl
, lib
, autoPatchelfHook
, glibc
, glib
, mpi
, autoAddDriverRunpath
, libxml2
, ncurses
, gmp
, python312
, python311
, python310
, libibmad
, libibumad
, mesa
, wayland
, libxcb
}:
stdenv.mkDerivation rec {
  name = "nvidia-hpc-sdk-${version}";
  version = "25.7";
  platform = "Linux_x86_64";
  # For localy downloaded offline installers
  #src = /home/tony/Downloads/nvhpc_2025_257_Linux_x86_64_cuda_12.9.tar.gz;
  src = (fetchTarball {
    url = "https://developer.download.nvidia.com/hpc-sdk/25.7/nvhpc_2025_257_Linux_x86_64_cuda_12.9.tar.gz";
    sha256 = "0dil5mp28igirjq2zqzbww5jsmsppq1dfpfqch5zmksk7ci1fxn5";
  });

  nativeBuildInputs = [ autoPatchelfHook autoAddDriverRunpath ];

  buildInputs = [
    mpi
    stdenv.cc.cc.lib
    glibc
    glib
    gmp
    python312
    python311
    python310
    libxml2
    ncurses
    openssl
    libibmad
    libibumad
    wayland
    mesa
    libxcb
  ];
  # propagatedBuildInputs = [ glibc glib fftw fftwQuad fftwFloat fftwLongDouble fftwMpi openssl ];
  dontConfigure = true;
  dontBuild = true;
  phases = [ "unpackPhase" "patchPhase" "installPhase" "fixupPhase" ];

  libPath = lib.makeLibraryPath [
    mpi
    stdenv.cc.cc.lib
    glibc
    glib
    gmp
    ncurses
    python312
    python311
    python310
    libxml2
    openssl
    libibmad
    libibumad
  ];
  autoPatchelfIgnoreMissingDeps = [
    "libpython3.9.so.1.0"
    "libpython3.8.so.1.0"
    "libibverbs.so.1"
    "libcrypto.so.1"
    "*"
  ];

  patchPhase = ''
    patchShebangs  --build ./install
    patchShebangs --build install_components/install*
  '';

  installPhase = ''
        mkdir -p $out
        echo $(pwd)
        echo "Installing nvhpc_sdk to $out"
        export NVHPC_SILENT=true
        export NVHPC_INSTALL_DIR=$out
        ./install
        installDir=$out/${platform}/${version}
        if [ ! -d "$installDir" ]; then
    	  echo "ERROR: nvidia hpc-sdk installation not found at $installDir"
    	  exit 1
        fi
  '';

  fixupPhase = ''
    # Patch ELF binaries
    autoPatchelf $out
    # find $out -type f \( -executable -o -name "*.so*" \) -print0 | while IFS= read -r -d $'\0' file; do
    #   if isELF "$file"; then
    #     echo "Patching $file"
    #     patchelf --add-rpath "${libPath}:$out/${platform}/${version}/cuda/12.9/targets/x86_64-linux/lib/" "$file">/dev/null || true
    #   fi
    # done
    patchShebangs --host $out/${platform}/${version}/compilers/bin/makelocalrc
  '';

  meta = with lib;{
    description = "nvidia hpc-sdk";
    homepage = "https://developer.nvidia.com/hpc-sdk";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ maintainers.tonywu20 ];
  };
}
