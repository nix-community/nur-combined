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
  ...
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

  postPatch = ''
    rm -rf subprojects/vkroots
    cp -r ${sources.vkroots.src} subprojects/vkroots
    chmod -R +w subprojects/vkroots
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Vulkan layer utilizing a small color management / HDR protocol for experimentation";
    homepage = "https://github.com/Zamundaaa/VK_hdr_layer";
    license = licenses.mit;
  };
}
