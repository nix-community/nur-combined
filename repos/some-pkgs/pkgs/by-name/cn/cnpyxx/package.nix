{ lib
, stdenv
, fetchFromGitLab
, cmake
, boost
, libzip
, range-v3
}:

stdenv.mkDerivation rec {
  pname = "cnpypp";
  version = "2.3.0";

  src = fetchFromGitLab {
    domain = "gitlab.iap.kit.edu";
    owner = "mreininghaus";
    repo = "cnpypp";
    rev = "v${version}";
    hash = "sha256-j8vK+niU/H+s2tJ1PphLDjSrgJm0BmruvnJMjJb1OkU=";
  };
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace 'install(TARGETS "cnpy++"' 'install(TARGETS "cnpy++" EXPORT "cnpy++Targets"'
    cat <<\EOF >> CMakeLists.txt
    install(
      EXPORT "cnpy++Targets"
      FILE "cnpy++Config.cmake"
      DESTINATION ''${CMAKE_INSTALL_LIBDIR}/cmake/cnpy++
      NAMESPACE cnpy++::
    )
    EOF
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    boost
    range-v3
    libzip
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20" # std::span<>
  ];

  meta = with lib; {
    broken = stdenv.isDarwin; # <ranges> and concepts with older llvm...
    description = "Maximilian Reininghaus's fork of cnpy";
    homepage = "https://gitlab.iap.kit.edu/mreininghaus/cnpypp";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = lib.platforms.unix;
  };
}
