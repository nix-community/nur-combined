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
  version = "1.1.10";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "vsg-dev";
    repo = "vsgXchange";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bnHAJYWd6QsmQCyryL4bxJdICpBVoxxEKRI50OoGd2Q=";
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
