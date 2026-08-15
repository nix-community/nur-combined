{
  lib,
  stdenv,
  fetchurl,
  patchelf,

  alsa-lib,
  glib,
  libdrm,
  libGL,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
  libxkbcommon,
  mesa,
  pipewire,
  pulseaudio,
  vulkan-loader,
  wayland,
}:

let
  version = "1.15.0";

  runtimeLibs = lib.makeLibraryPath [
    alsa-lib
    glib
    libdrm
    libGL
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libxkbcommon
    mesa
    pipewire
    pulseaudio
    stdenv.cc.cc.lib
    vulkan-loader
    wayland
  ];
in
stdenv.mkDerivation {
  pname = "zedg";
  inherit version;

  src = fetchurl {
    url = "https://github.com/x6nux/zed-globalization/releases/download/v${version}/zedg-zh-cn-linux-x86_64-v${version}.tar.gz";
    hash = "sha256-udeY4fjmWdVKDfQ9CRQiH4tOCl/4VO0eUbCu3K0SFdE=";
  };

  nativeBuildInputs = [ patchelf ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/zedg $out/bin/zedg
    ln -s zedg $out/bin/zed
    install -Dm755 libexec/zedg $out/libexec/zedg

    install -Dm644 share/applications/zedg.desktop $out/share/applications/zedg.desktop
    for icon in share/icons/hicolor/*/apps/zedg.png; do
      size=$(echo "$icon" | sed 's|.*hicolor/\([^/]*\)/.*|\1|')
      install -Dm644 "$icon" "$out/share/icons/hicolor/$size/apps/zedg.png"
    done

    runHook postInstall
  '';

  postFixup = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${runtimeLibs}" \
      $out/bin/zedg
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${runtimeLibs}" \
      $out/libexec/zedg
  '';

  meta = {
    description = "Zed Editor Chinese Localization (Zed 编辑器汉化版)";
    homepage = "https://github.com/x6nux/zed-globalization";
    license = lib.licenses.mit;
    mainProgram = "zedg";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
