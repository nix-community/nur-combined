{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  makeWrapper,
  autoPatchelfHook,
  fontconfig,
  glib,
  gsettings-desktop-schemas,
  libglvnd,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxxf86vm,
  systemd,
  vulkan-loader,
  wayland,
  extraRuntimeTools ? [ ],
}:

let
  # winit, glutin, dan wgpu memuat library windowing, GL/EGL, dan Vulkan secara dinamis via dlopen.
  dlopenLibs = [
    libglvnd
    libx11
    libxcb
    libxcursor
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxxf86vm
    wayland
    vulkan-loader
  ];

  # Utilitas dasar Linux (font, tema dark mode, trash, power control).
  # Tool media seperti ffmpeg, yt-dlp, dan gallery-dl otomatis dibaca dari PATH pengguna
  # (atau dapat ditambahkan lewat parameter `extraRuntimeTools`).
  runtimeTools = [
    fontconfig
    glib
    systemd
  ]
  ++ extraRuntimeTools;
in
stdenv.mkDerivation rec {
  pname = "misterdownloadmanager";
  version = "0.5.2";

  src = fetchurl {
    url = "https://github.com/anefzaoui/misterdownloadmanager/releases/download/v${version}/MisterDownloadManager-${version}-linux-x86_64.deb";
    sha256 = "sha256-nTMNloSggZzqmHyudgGxxQePx3Uglepuay8v7wNakuE=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    glib
    libglvnd
    libx11
    libxcb
    libxkbcommon
    wayland
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share $out/lib/mozilla/native-messaging-hosts

    cp -r usr/bin/* $out/bin/
    cp -r usr/share/* $out/share/

    # Simpan salinan manifest native messaging yang menunjuk ke path Nix store paket ini
    if [ -f usr/lib/mozilla/native-messaging-hosts/com.misterdownloadmanager.host.json ]; then
      substitute usr/lib/mozilla/native-messaging-hosts/com.misterdownloadmanager.host.json \
        $out/lib/mozilla/native-messaging-hosts/com.misterdownloadmanager.host.json \
        --replace-fail "/usr/bin/misterdownloadmanager-nmhost" "$out/bin/misterdownloadmanager-nmhost"
    fi

    if [ -f etc/opt/chrome/native-messaging-hosts/com.misterdownloadmanager.host.json ]; then
      mkdir -p $out/share/misterdownloadmanager/native-messaging-hosts
      substitute etc/opt/chrome/native-messaging-hosts/com.misterdownloadmanager.host.json \
        $out/share/misterdownloadmanager/native-messaging-hosts/chromium.json \
        --replace-fail "/usr/bin/misterdownloadmanager-nmhost" "$out/bin/misterdownloadmanager-nmhost"
    fi

    wrapProgram $out/bin/misterdownloadmanager \
      --suffix PATH : "${lib.makeBinPath runtimeTools}" \
      --suffix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"

    runHook postInstall
  '';

  # Tambahkan library dlopen ke RUNPATH biner asli setelah fixupPhase agar tidak dipangkas.
  postFixup = ''
    patchelf --add-rpath "${lib.makeLibraryPath dlopenLibs}" $out/bin/.misterdownloadmanager-wrapped
  '';

  meta = with lib; {
    description = "Open-source, clean-room download manager written in pure Rust with torrents, video downloads, and browser integration";
    homepage = "https://misterdownloadmanager.com";
    changelog = "https://github.com/anefzaoui/misterdownloadmanager/blob/v${version}/CHANGELOG.md";
    license = licenses.gpl3Plus;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "misterdownloadmanager";
    platforms = [ "x86_64-linux" ];
  };
}
