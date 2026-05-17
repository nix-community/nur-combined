{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "lexy";
  version = "2025.05.0";

  src = fetchFromGitHub {
    owner = "foonathan";
    repo = "lexy";
    rev = "v${version}";
    sha256 = "sha256-ONoMGos5Xo2JqvXwLmq6B7XH1eG25FVkSbgYKvr5QpI=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DLEXY_BUILD_TESTS=OFF"
    "-DLEXY_BUILD_EXAMPLES=OFF"
    "-DLEXY_ENABLE_INSTALL=ON"
  ];

  # The default build produces only a Release configuration in the exported
  # CMake targets file.  Consumers building in Debug mode cannot resolve
  # foonathan::lexy::file (a STATIC IMPORTED target) and therefore lose
  # transitive INTERFACE_INCLUDE_DIRECTORIES propagation from lexy::core.
  # Appending a Debug entry that points to the same Release artifact fixes this.
  postInstall = ''
        local targets="$out/lib/cmake/lexy/lexyTargets-release.cmake"
        cat >> "$targets" << EOF

    # Debug configuration — maps to the same Release artifact so that consumers
    # building with CMAKE_BUILD_TYPE=Debug get proper include propagation.
    set_property(TARGET foonathan::lexy::file
        APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
    set_target_properties(foonathan::lexy::file PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
        IMPORTED_LOCATION_DEBUG "$out/lib/liblexy_file.a")
    EOF
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A parser combinator library for C++17 and onwards.";
    homepage = "https://github.com/foonathan/lexy";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
