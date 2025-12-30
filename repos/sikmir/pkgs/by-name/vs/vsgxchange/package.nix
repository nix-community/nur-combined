{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  glslang,
  libxcb,
  vulkan-headers,
  vulkan-loader,
  vulkanscenegraph,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vsgxchange";
  version = "1.1.8";

  src = fetchFromGitHub {
    owner = "vsg-dev";
    repo = "vsgXchange";
    tag = "v${finalAttrs.version}";
    hash = "sha256-R/6D81SN7Po8tsx1vEjQHj79MjVwpEDHswMmiekeuMs=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    glslang
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
