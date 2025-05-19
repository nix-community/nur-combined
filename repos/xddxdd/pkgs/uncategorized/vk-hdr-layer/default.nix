{
  stdenv,
  sources,
  lib,
  meson,
  ninja,
  pkg-config,
  vulkan-headers,
  vulkan-loader,
  wayland-scanner,
  wayland,
  xorg,
}:
stdenv.mkDerivation rec {
  inherit (sources.vk-hdr-layer) pname version src;
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
    xorg.libX11
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Vulkan layer utilizing a small color management / HDR protocol for experimentation";
    homepage = "https://github.com/Zamundaaa/VK_hdr_layer";
    license = lib.licenses.mit;
  };
}
