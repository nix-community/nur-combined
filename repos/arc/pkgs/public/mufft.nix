{ stdenv, cmake, fetchFromGitHub }: stdenv.mkDerivation rec {
  pname = "muFFT";
  version = "2019-02-15";

  src = fetchFromGitHub {
    owner = "Themaister";
    repo = pname;
    rev = "47bb08652eab399c2c7d460abe5184857110f130";
    sha256 = "0s3qk6ma10jcqf091xm7swqbccmki2phsqs1jgskplym2xr6lgkn";
  };

  passAsFile = [ "install" ];
  install = ''
    set_target_properties(muFFT PROPERTIES OUTPUT_NAME mufft)
    set_target_properties(muFFT PROPERTIES PRIVATE_HEADER fft_internal.h)
    set_target_properties(muFFT PROPERTIES PUBLIC_HEADER fft.h)
    set(VERSION $ENV{version})
    set(PREFIX $ENV{out})
    configure_file(
      ''${PROJECT_SOURCE_DIR}/mufft.pc.in
      ''${PROJECT_BINARY_DIR}/mufft.pc
      @ONLY
    )
    install(TARGETS muFFT
      LIBRARY DESTINATION ''${CMAKE_INSTALL_LIBDIR}
      PUBLIC_HEADER DESTINATION ''${CMAKE_INSTALL_INCLUDEDIR}
    )
    install(FILES ''${CMAKE_CURRENT_BINARY_DIR}/mufft.pc
      DESTINATION ''${CMAKE_INSTALL_LIBDIR}/pkgconfig
    )
  '';

  postPatch = ''
    sed -i 's/muFFT STATIC/muFFT SHARED/' CMakeLists.txt
    cat $installPath >> CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DMUFFT_ENABLE_FFTW=OFF"
  ];
}
