{ lib
, stdenv
, cmake
, fetchFromGitHub
, boost
, eigen
, nlohmann_json
, pybind11
, python
, spdlog
, callPackage
}:

let
  cubic-interpolation = callPackage ./cubic-interpolation.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "proposal";
  version = "7.6.2";

  src = fetchFromGitHub {
    owner = "tudo-astroparticlephysics";
    repo = "PROPOSAL";
    rev = finalAttrs.version;
    hash = "sha256-R1x1+wG504nx6X1aZ0GuKzKVTTOUuyST7r5dM65JCjw=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ pybind11 python ];
  propagatedBuildInputs = [ cubic-interpolation spdlog nlohmann_json boost eigen ];

  postPatch = ''
    substituteInPlace src/PROPOSAL/Config.cmake.in \
      --replace-fail '@PACKAGE_PREFIX_DIR@' '@CMAKE_INSTALL_PREFIX@'
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DBUILD_PYTHON=ON"
    "-DBUILD_TESTING=OFF"
    "-DBUILD_EXAMPLE=OFF"
    "-DBUILD_DOCUMENTATION=OFF"
    "-DPython_EXECUTABLE=${python.interpreter}"
  ];

  postInstall = ''
    mkdir -p "$out/${python.sitePackages}"
    mv "$out/lib/proposal"*.so "$out/${python.sitePackages}/"
  '';

  passthru.pythonModule = python;

  meta = {
    description = "Monte Carlo propagation of leptons and gamma rays through matter";
    homepage = "https://github.com/tudo-astroparticlephysics/PROPOSAL";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
  };
})
