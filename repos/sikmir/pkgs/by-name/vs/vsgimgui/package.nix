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
  pname = "vsgimgui";
  version = "0.8.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "vsg-dev";
    repo = "vsgImGui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aThT+iY4j3maCuxyzg0iusMwTMz10v339Ku5aLx4wKM=";
    fetchSubmodules = true;
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
    description = "Integration of VulkanSceneGraph with ImGui";
    homepage = "https://github.com/vsg-dev/vsgImGui";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.hostPlatform.isDarwin;
  };
})
