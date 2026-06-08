{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  python3,
  ninja,
  glslang,
  shaderc,
  rapidjson,
  spirv-cross,
  spirv-headers,
  spirv-tools,
  vulkan-headers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pyroveil";
  version = "0-unstable-2025-11-17";

  src = fetchFromGitHub {
    owner = "HansKristian-Work";
    repo = "pyroveil";
    rev = "e1f547372cf1b9d14da56621716d2137088d0061";
    hash = "sha256-Ym9dTijzdYOKgHPya2dj+8/e1fJhTeUGKqszSeZ+PB4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  buildInputs = [
    glslang
    shaderc
    rapidjson
    spirv-cross
    spirv-headers
    spirv-tools
    vulkan-headers
  ];

  meta = {
    description = "Vulkan layer to replace shaders or roundtrip them to workaround driver bugs";
    homepage = "https://github.com/HansKristian-Work/pyroveil";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pyroveil";
    platforms = lib.platforms.linux;
  };
})
