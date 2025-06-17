{ stdenv
, lib
, numactl
, autoPatchelfHook
, bash
, glibc
, glib
, file
, fftw
, fftwQuad
, fftwFloat
, fftwLongDouble
, fftwMpi
, openssl
, gfortran
, mpi
}:
stdenv.mkDerivation rec {
  name = "amd-aocl-${compiler}-${version}";
  version = "5.1.0";
  compiler = "gcc";
  src = (fetchTarball {
    url = "https://download.amd.com/developer/eula/aocl/aocl-5-1/aocl-linux-gcc-5.1.0.tar.gz";
    sha256 = "0nkw3bf1wh8jcc59v8zz539pwm4ry4midr68dyj5l05bcf230i4r";
  });

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    mpi
    numactl
    stdenv.cc.cc.lib
    glibc
    glib
    fftw
    fftwQuad
    fftwFloat
    fftwLongDouble
    fftwMpi
    openssl
    gfortran.cc
  ];
  # propagatedBuildInputs = [ glibc glib fftw fftwQuad fftwFloat fftwLongDouble fftwMpi openssl ];
  dontConfigure = true;
  dontBuild = true;
  phases = [ "unpackPhase" "patchPhase" "installPhase" "fixupPhase" ];

  libPath = lib.makeLibraryPath [
    mpi
    numactl
    stdenv.cc.cc.lib
    glibc
    glib
    fftw
    fftwQuad
    fftwFloat
    fftwLongDouble
    fftwMpi
    openssl
    gfortran.cc
  ];

  patchPhase = ''
    patchShebangs  --build ./install.sh
  '';

  installPhase = ''
        mkdir -p $out
        echo $(pwd)
        echo "Installing AOCL to $out"
        ./install.sh -t $out
        installDir=$out/${version}/${compiler}
        if [ ! -d "$installDir" ]; then
    	  echo "ERROR: AOCL installation not found at $installDir"
    	  exit 1
        fi
  '';

  fixupPhase = ''
                # Patch ELF binaries
                  find $out -type f \( -executable -o -name "*.so*" \) -print0 | while IFS= read -r -d $'\0' file; do
                    if isELF "$file"; then
                      echo "Patching $file"
                      patchelf --add-rpath "${libPath}:$out/${version}/${compiler}/lib" "$file"
                    fi
                  done
            	# Create Nix-specific module file
            	mkdir -p $out/nix-support
        		modulefile="aocl-linux-${compiler}-${version}"_module
        		cat >$out/nix-support/$modulefile<<EOF
          #%Module1.0#####################################################################
          proc ModulesHelp { } {
        	global version AOCLhome
        	puts stderr "\tAOCL \n"
        	puts stderr "\tloads AMD Optimizing CPU Libraries (AOCL) setup \n"
          }
          module-whatis "loads AOCL Libraries setup "
          set AOCLhome $out/aocl/${version}/${compiler}
          prepend-path AOCLhome $AOCLhome
          prepend-path AOCL_ROOT $AOCLhome
          prepend-path LIBRARY_PATH $AOCLhome/lib
          prepend-path LD_LIBRARY_PATH $AOCLhome/lib
          prepend-path C_INCLUDE_PATH $AOCLhome/include
          prepend-path CPLUS_INCLUDE_PATH $AOCLhome/include
          prepend-path LD_LIBRARY_PATH $AOCLhome/lib
          prepend-path LIBRARY_PATH $AOCLhome/lib
    EOF
  '';

  meta = with lib;{
    description = "AMD Optimizing CPU Libraries";
    homepage = "https://developer.amd.com/amd-aocl/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ maintainers.tonywu20 ];
  };
}
