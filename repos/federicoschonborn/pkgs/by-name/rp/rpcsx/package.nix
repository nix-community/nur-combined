{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
, glfw
, glslang
, libunwind
, sox
, spirv-cross
, spirv-tools
, vulkan-headers
, vulkan-loader
}:

stdenv.mkDerivation {
  pname = "rpcsx";
  version = "unstable-2023-08-20";

  src = fetchFromGitHub {
    owner = "RPCSX";
    repo = "rpcsx";
    rev = "7ea6f3d91aff77356faf093f227db4b780b8044f";
    hash = "sha256-33PDcXfNQTfUrcyWzKqUn5DqizYCjKy5gpgh/2rVzhQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    glfw
    glslang
    libunwind
    sox
    spirv-cross
    spirv-tools
    vulkan-headers
    vulkan-loader
  ];

  postPatch = ''
    substituteInPlace --replace "-march=native" "-mfsgsbase" rpcsx-os/CMakeLists.txt
  '';

  meta = with lib; {
    description = "";
    homepage = "https://github.com/RPCSX/rpcsx";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ federicoschonborn ];
    # error: inlining failed in call to 'always_inline' 'long long unsigned int _readfsbase_u64()': target specific option mismatch
    broken = true;
  };
}
