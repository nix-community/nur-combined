{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  wayland-scanner,
  cairo,
  fontconfig,
  pango,
  wayland,
  wayland-protocols,
  curl,
  libappindicator,
  gdk-pixbuf,
  openssl,
  json_c,
  glib,
  libexttextcat,
  wrapGAppsHook3,
}:

{
  pname,
  version,
  src,
}:

stdenv.mkDerivation {
  inherit pname version src;

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "install_dir: '/etc/wshowlyrics'" "install_dir: '$out/etc/wshowlyrics'" \
      --replace-fail "install_dir: '/usr/lib/systemd/user'" "install_dir: '$out/lib/systemd/user'"

    substituteInPlace src/user_experience/config/config.c \
      --replace-fail "/etc/wshowlyrics/settings.ini" "$out/etc/wshowlyrics/settings.ini" \
      --replace-fail "/etc/wshowlyrics/settings.ini.example" "$out/etc/wshowlyrics/settings.ini.example" \
      --replace-fail "/usr/share/wshowlyrics/settings.ini.example" "$out/share/wshowlyrics/settings.ini.example" \
      --replace-fail '"/etc/"' '"'$out/etc/'"' \
      --replace-fail '"/usr/share/"' '"'$out/share/'"'

    substituteInPlace src/utils/lang_detect/lang_detect.c \
      --replace-fail "/usr/share/libexttextcat/fpdb.conf" "${libexttextcat}/share/libexttextcat/fpdb.conf" \
      --replace-fail "/usr/share/libexttextcat/" "${libexttextcat}/share/libexttextcat/"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    fontconfig
    pango
    wayland
    wayland-protocols
    curl
    libappindicator
    gdk-pixbuf
    openssl
    json_c
    glib
    libexttextcat
  ];

  postInstall = ''
    mv $out/bin/lyrics $out/bin/wshowlyrics

    if [ -f "$out/lib/systemd/user/wshowlyrics.service" ]; then
      substituteInPlace $out/lib/systemd/user/wshowlyrics.service \
        --replace-fail "/usr/bin/wshowlyrics" "$out/bin/wshowlyrics"
    fi
  '';

  mesonFlags = [
    "--sysconfdir=${placeholder "out"}/etc"
  ];

  meta = {
    description = "Wayland Lyrics Overlay inspired by LyricsX";
    homepage = "https://github.com/unstable-code/lyrics";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ "unstable-code" ];
    mainProgram = "wshowlyrics";
    platforms = lib.platforms.linux;
  };
}
