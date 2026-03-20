{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "gtl";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "greg7mdp";
    repo = "gtl";
    rev = "b4ac266c9008b6a1ea3d92633adb2066c05a48e6";
    sha256 = "sha256-c0Mwzems8sGeYgGe0LKsk+5v2KR2js/StXInTR3GZ6o=";
  };

  nativeBuildInputs = [ cmake ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'target_sources(''${PROJECT_NAME} INTERFACE ''${GTL_HEADERS})' '# stripped for install-export compatibility' \
      --replace-fail 'export(EXPORT ''${PROJECT_NAME}-targets' 'install(EXPORT gtl-targets
            NAMESPACE gtl::
            FILE gtlTargets.cmake
            DESTINATION lib/cmake/gtl' \
      --replace-fail 'FILE "''${CMAKE_CURRENT_BINARY_DIR}/''${PROJECT_NAME}Targets.cmake")' ')'
  '';

  cmakeFlags = [
    "-DGTL_INSTALL=ON"
    "-DGTL_BUILD_TESTS=OFF"
    "-DGTL_BUILD_EXAMPLES=OFF"
    "-DGTL_BUILD_BENCHMARKS=OFF"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  postInstall = ''
    mkdir -p $out/lib/cmake/gtl
    cat > $out/lib/cmake/gtl/gtlConfig.cmake <<'EOF'
include("''${CMAKE_CURRENT_LIST_DIR}/gtlTargets.cmake")
EOF
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Greg's template library of useful classes";
    homepage = "https://github.com/greg7mdp/gtl";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
