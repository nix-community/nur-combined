{ stdenv, lib, fetchFromGitHub, makeWrapper, cmake, pkgconfig
, boost, curl, expat, glew, libpng, tbb, wxGTK31
, gtest, nlopt, xorg
}:
let
  nloptVersion = if lib.hasAttr "version" nlopt
                 then lib.getAttr "version" nlopt
                 else "2.4";
in
stdenv.mkDerivation rec {
  name = "slic3r-prusa-edition-${version}";
  version = "1.42.0-alpha5";

  enableParallelBuilding = true;

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkgconfig
  ];

  # We could add Eigen, but it doesn't currently compile with the version in
  # nixpkgs.
  buildInputs = [
    boost
    curl
    expat
    glew
    libpng
    tbb
    wxGTK31
    xorg.libX11
  ] ++ checkInputs;

  checkInputs = [ gtest ];

  # The build system uses custom logic - defined in
  # xs/src/libnest2d/cmake_modules/FindNLopt.cmake in the package source -
  # for finding the nlopt library, which doesn't pick up the package in the nix store.
  # We need to set the path via the NLOPT environment variable instead.
  NLOPT = "${nlopt}";

  prePatch = ''
    # In nix ioctls.h isn't available from the standard kernel-headers package
    # on other distributions. As the copy in glibc seems to be identical to the
    # one in the kernel, we use that one instead.
    sed -i 's|"/usr/include/asm-generic/ioctls.h"|<asm-generic/ioctls.h>|g' src/libslic3r/GCodeSender.cpp
  '' + lib.optionalString (lib.versionOlder "2.5" nloptVersion) ''
    # Since version 2.5.0 of nlopt we need to link to libnlopt, as libnlopt_cxx
    # now seems to be integrated into the main lib.
    sed -i 's|nlopt_cxx|nlopt|g' src/libnest2d/cmake_modules/FindNLopt.cmake
  '';

  src = fetchFromGitHub {
    owner = "prusa3d";
    repo = "Slic3r";
    sha256 = "0mlpaavrdmb69dqrhgzs71950idx3bnrvv1w97vqy22ygwv0rdbc";
    rev = "version_${version}";
  };

  cmakeFlags = [ "-DSLIC3R_FHS=1" ];

  meta = with stdenv.lib; {
    description = "G-code generator for 3D printer";
    homepage = https://github.com/prusa3d/Slic3r;
    license = licenses.agpl3;
    maintainers = with maintainers; [ moredread ];
  };
}
