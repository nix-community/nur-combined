{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  python3Packages,
  pythonSupport ? false,
  cudaSupport ? false,
  assimp,
  eigen,
  glew,
  nanoflann,
  glfw,
  jsoncpp,
  libpng,
  liblzf,
  tinygltf,
  tinyobjloader,
  filament,
  qhull,
  gtest,
  imgui,
  fmt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "open3d";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "isl-org";
    repo = "Open3D";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VMykWYfWUzhG+Db1I/9D1GTKd3OzmSXvwzXwaZnu8uI=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    eigen
    libpng
    liblzf
    assimp
    glew
    nanoflann
    glfw
    jsoncpp
    tinygltf
    imgui
    filament
    tinyobjloader
    qhull
    fmt
    gtest
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_CUDA_MODULE" cudaSupport)
    (lib.cmakeBool "BUILD_PYTHON_MODULE" pythonSupport)
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_UNIT_TESTS=ON"
    "-DBUILD_ISPC_MODULE=OFF"  # TODO: it really tries to fetch stuff
    #"-DENABLE_HEADLESS_RENDERING=ON" it is either that or GUI
    "-DUSE_SYSTEM_BLAS=ON"
    "-DUSE_SYSTEM_ASSIMP=ON"
    "-DUSE_SYSTEM_CURL=ON"
    "-DUSE_SYSTEM_CUTLASS=ON"
    "-DUSE_SYSTEM_EIGEN3=ON"
    "-DUSE_SYSTEM_EMBREE=ON"
    "-DUSE_SYSTEM_FILAMENT=ON"
    "-DUSE_SYSTEM_FMT=ON"
    "-DUSE_SYSTEM_GLEW=ON"
    "-DUSE_SYSTEM_GLFW=ON"
    "-DUSE_SYSTEM_GOOGLETEST=ON"
    "-DUSE_SYSTEM_IMGUI=ON"
    "-DUSE_SYSTEM_JPEG=ON"
    "-DUSE_SYSTEM_JSONCPP=ON"
    "-DUSE_SYSTEM_LIBLZF=ON"
    "-DUSE_SYSTEM_MSGPACK=ON"
    "-DUSE_SYSTEM_NANOFLANN=ON"
    "-DUSE_SYSTEM_OPENSSL=ON"
    "-DUSE_SYSTEM_PNG=ON"
    "-DUSE_SYSTEM_PYBIND11=ON"
    "-DUSE_SYSTEM_QHULLCPP=ON"
    "-DUSE_SYSTEM_STDGPU=ON"
    "-DUSE_SYSTEM_TBB=ON"
    "-DUSE_SYSTEM_TINYGLTF=ON"
    "-DUSE_SYSTEM_TINYOBJLOADER=ON"
    "-DUSE_SYSTEM_VTK=ON"
    "-DUSE_SYSTEM_ZEROMQ=ON"
    "-DBUILD_VTK_FROM_SOURCE=OFF"
    "-DBUILD_FILAMENT_FROM_SOURCE=OFF"
    "-DPREFER_OSX_HOMEBREW=OFF"
  ];

  propagatedBuildInputs = lib.optionals pythonSupport [
    python3Packages.pinocchio
  ];

  meta = {
    description = "Open3D: A Modern Library for 3D Data Processing";
    homepage = "https://github.com/isl-org/Open3D";
    changelog = "https://github.com/isl-org/Open3D/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nim65s ];
  };
})
