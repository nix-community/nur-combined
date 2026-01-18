{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "socketw";
  version = "3.10.27";

  src = fetchFromGitHub {
    owner = "RigsOfRods";
    repo = "SocketW";
    rev = "35cd91e18dfa14419879b737b7d01dacdf39e610";
    hash = "sha256-wtDq60eYslroTVVwulDSIr4irY6cg1p3ZZ3oeMGx5Fg=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DCMCM_LOCAL_RESOLVE_URL=file:///build/source/cmake"
  ];

  postPatch = ''
    mkdir -p cmake/modules
    cat > cmake/modules/JoinPaths.cmake <<'EOF'
function(join_paths out_var)
  set(result "")
  foreach(part IN LISTS ARGN)
    if(part STREQUAL "")
      continue()
    endif()
    if(part MATCHES "^/")
      set(result "''${part}")
      continue()
    endif()
    if(result STREQUAL "")
      set(result "''${part}")
    elseif(result MATCHES "/$")
      set(result "''${result}''${part}")
    else()
      set(result "''${result}/''${part}")
    endif()
  endforeach()
  set(''${out_var} "''${result}" PARENT_SCOPE)
endfunction()
EOF
  '';

  meta = with lib; {
    description = "Cross-platform socket abstraction library used by Rigs of Rods";
    homepage = "https://github.com/RigsOfRods/SocketW";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
})
