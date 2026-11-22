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
  version = "813375e";

  src = fetchFromGitHub {
    owner = "RigsOfRods";
    repo = "SocketW";
    rev = finalAttrs.version;
    hash = "sha256-Mv/dt+UzbHeevvCiLF5Yzn0ra7sbuDqp0P4awf3GHSU=";
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
  ];

  # Off by default in nixpkgs; builds and links cleanly with the CET shadow
  # stack, so opt in here.
  hardeningEnable = [ "shadowstack" ];

  # CMakeCM's file(DOWNLOAD) of file:// JoinPaths.cmake fails on Darwin.
  # Vendor JoinPaths and drop the CMakeCM network/local resolver entirely.
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
    substituteInPlace CMakeLists.txt \
      --replace-fail 'include(CMakeCM)' '# include(CMakeCM)' \
      --replace-fail 'include(JoinPaths)' 'include("''${CMAKE_SOURCE_DIR}/cmake/modules/JoinPaths.cmake")'
  '';

  meta = with lib; {
    description = "Cross-platform socket abstraction library used by Rigs of Rods";
    homepage = "https://github.com/RigsOfRods/SocketW";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
})
