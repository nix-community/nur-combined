{ lib
, stdenv
, callPackage
, alsa-lib
, autoPatchelfHook
, brotli
, ffmpeg
, libdrm
, libGL
, libunwind
, libva
, libvdpau
, libxkbcommon
, nix-update-script
, SDL2
, openssl
, pipewire
, pulseaudio
, vulkan-loader
, wayland
, x264
, xorg
, xvidcore
, zlib
}:
let
  sources = callPackage ../../_sources/generated.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "alvr";
  version = lib.removePrefix "v" sources.alvr.version;

  inherit (sources.alvr) src;

  alvrSrc = sources.alvr-source.src;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    libunwind
    libva
    libvdpau
    pipewire
    SDL2
    vulkan-loader
    zlib
    stdenv.cc.cc.lib
  ];

  runtimeDependencies = [
    brotli
    ffmpeg
    libdrm
    libGL
    libxkbcommon
    openssl
    pipewire
    pulseaudio
    wayland
    x264
    xorg.libX11
    xorg.libXcursor
    xorg.libxcb
    xorg.libXi
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/applications
    cp -r ./* $out
    install -Dm444 $alvrSrc/alvr/xtask/resources/alvr.desktop -t $out/share/applications
    install -Dm444 $alvrSrc/alvr/xtask/flatpak/alvr_icon.png $out/share/icons/hicolor/256x256/apps/alvr.png
    install -Dm444 $alvrSrc/alvr/xtask/firewall/ufw-alvr $out/share/alvr/ufw-alvr
    install -Dm755 ${./alvr-firewall-install.sh} $out/bin/alvr-firewall-install

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Stream VR games from your PC to your headset via Wi-Fi";
    homepage = "https://github.com/alvr-org/ALVR/";
    changelog = "https://github.com/alvr-org/ALVR/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = with maintainers; [ passivelemon ];
    platforms = platforms.linux;
    mainProgram = "alvr_dashboard";
  };
})
