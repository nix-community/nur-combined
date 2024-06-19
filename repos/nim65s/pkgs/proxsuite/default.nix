{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cereal,
  cmake,
  doxygen,
  eigen,
  jrl-cmakemodules,
  simde,
  matio,
  pythonSupport ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "proxsuite";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "simple-robotics";
    repo = "proxsuite";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3kzFYADk3sCMU827KowilPlmOqgv69DJ3mOb7623Qdg=";
  };

  patches = [
    (fetchpatch {
      name = "no-jrl.patch";
      url = "https://github.com/nim65s/proxsuite/commit/3da2323ec616d8977f19778ecfd8ed0988797d21.patch";
      hash = "sha256-BPtwogSwSXcEd5FM4eTTCq6LpGWvQ1SOCFmv/GVhl18=";
    })
    (fetchpatch {
      name = "no-cereal.patch";
      url = "https://github.com/nim65s/proxsuite/commit/90c47ea8b.patch";
      hash = "sha256-+HWYHLGtygjlvjM+FSD9WFDIwO+qPLlzci+7q42bo0I=";
    })
  ];

  postPatch = ''
    substituteInPlace test/CMakeLists.txt \
      --replace-fail "proxsuite_test(dense_maros_meszaros src/dense_maros_meszaros.cpp)" "" \
      --replace-fail "proxsuite_test(sparse_maros_meszaros src/sparse_maros_meszaros.cpp)" ""
  '';

  outputs = [
    "doc"
    "out"
  ];

  cmakeFlags = [
    "-DBUILD_DOCUMENTATION=ON"
    "-DINSTALL_DOCUMENTATION=ON"
    (lib.cmakeBool "BUILD_PYTHON_INTERFACE" pythonSupport)
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    doxygen
  ];
  propagatedBuildInputs = [
    cereal
    eigen
    jrl-cmakemodules
    simde
  ];
  checkInputs = [ matio ];

  doCheck = true;

  meta = {
    description = "The Advanced Proximal Optimization Toolbox";
    homepage = "https://github.com/Simple-Robotics/proxsuite";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
