{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  meson,
  ninja,
  pkg-config,
  vulkan-headers,
  vulkan-loader,
  wayland-scanner,
  wayland,
  libX11,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vk-hdr-layer";
  version = "0-unstable-2026-08-05";
  src = fetchFromGitHub {
    owner = "Zamundaaa";
    repo = "VK_hdr_layer";
    rev = "8ec9b54d21f7474a9c406cf7366598a298d145f7";
    fetchSubmodules = true;
    hash = "sha256-gD+BOfM/2QN0UxhlVZNgsHCgIJkGZppHfM1ONsnMe2U=";
  };
  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];
  buildInputs = [
    vulkan-headers
    vulkan-loader
    wayland
    wayland-scanner
    libX11
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Vulkan layer utilizing a small color management / HDR protocol for experimentation";
    homepage = "https://github.com/Zamundaaa/VK_hdr_layer";
    license = lib.licenses.mit;
  };
})
