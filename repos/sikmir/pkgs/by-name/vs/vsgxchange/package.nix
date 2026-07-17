{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  curl,
  draco,
  glslang,
  ktx-tools,
  libxcb,
  vulkan-headers,
  vulkan-loader,
  vulkanscenegraph,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vsgxchange";
  version = "1.1.13";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "vsg-dev";
    repo = "vsgXchange";
    tag = "v${finalAttrs.version}";
    hash = "sha256-orjMGdXQj3AdLL431WVAbt4tt0Rl2L7a+LOD4vpNN3M=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    curl
    draco
    glslang
    ktx-tools
    libxcb
    vulkan-headers
    vulkan-loader
    vulkanscenegraph
  ];

  meta = {
    description = "Utility library for converting data+materials to/from VulkanSceneGraph";
    homepage = "https://github.com/vsg-dev/vsgXchange";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
