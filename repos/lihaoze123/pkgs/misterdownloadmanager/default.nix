{ lib
, stdenv
, fetchurl
, writeText
, dpkg
, autoPatchelfHook
, addDriverRunpath
, makeWrapper
, versionCheckHook
, cairo
, dbus
, dejavu_fonts
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libGL
, libX11
, libXcursor
, libXext
, libXfixes
, libXi
, libXrandr
, libxcb
, libxkbcommon
, pango
, vulkan-loader
, wayland
, wqy_zenhei
, xdg-utils
, zlib
,
}:

let
  pname = "misterdownloadmanager";
  version = "0.5.2";

  # MDM on Linux queries `fc-match -f "%{file}"` and loads raw font bytes at TTC index 0
  # without OpenType variable-font axis coordinates. Multi-weight VF/TTC collections such as
  # NotoSansCJK-VF.otf.ttc (index 0 = Thin, weight 0) or SourceHanSans.ttc (index 0 = ExtraLight)
  # render as faint/blurry hairlines at 11-12px. Reject those collections so fc-match selects
  # static Regular TrueType fonts (e.g. Segoe UI / Microsoft YaHei if installed, or DejaVu / WenQuanYi).
  fontsConf = writeText "mdm-fonts.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <include ignore_missing="yes">/etc/fonts/fonts.conf</include>

      <dir>${dejavu_fonts.minimal or dejavu_fonts}/share/fonts</dir>
      <dir>${wqy_zenhei}/share/fonts</dir>

      <selectfont>
        <rejectfont>
          <glob>*VF.otf*</glob>
          <glob>*VF.ttf*</glob>
          <glob>*Variable*</glob>
          <glob>*SegUIVar*</glob>
          <glob>*SourceHanSans*.ttc</glob>
          <glob>*SourceHanSerif*.ttc</glob>
          <glob>*Inter.ttc</glob>
          <glob>*msyhl.ttc</glob>
          <glob>*msjhl.ttc</glob>
        </rejectfont>
      </selectfont>
    </fontconfig>
  '';

  runtimeLibs = [
    cairo
    dbus
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libX11
    libXcursor
    libXext
    libXfixes
    libXi
    libXrandr
    libxcb
    libxkbcommon
    pango
    stdenv.cc.cc.lib
    vulkan-loader
    wayland
    zlib
  ];
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/anefzaoui/misterdownloadmanager/releases/download/v${version}/MisterDownloadManager-${version}-linux-x86_64.deb";
    hash = "sha256-nTMNloSggZzqmHyudgGxxQePx3Uglepuay8v7wNakuE=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    addDriverRunpath
    makeWrapper
  ];

  buildInputs = runtimeLibs;
  runtimeDependencies = map lib.getLib runtimeLibs;
  appendRunpaths = [ "${addDriverRunpath.driverLink}/lib" ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r usr/* "$out/"
    if [ -d etc ]; then
      cp -r etc "$out/"
    fi

    substituteInPlace "$out/share/applications/misterdownloadmanager.desktop" \
      --replace-quiet "Exec=misterdownloadmanager" "Exec=$out/bin/misterdownloadmanager"

    while IFS= read -r -d ''' manifest; do
      substituteInPlace "$manifest" \
        --replace-quiet "/usr/bin/misterdownloadmanager-nmhost" "$out/bin/misterdownloadmanager-nmhost"
    done < <(find "$out" -name 'com.misterdownloadmanager.host.json' -print0)

    wrapProgram "$out/bin/misterdownloadmanager" \
      --set-default FONTCONFIG_FILE "${fontsConf}" \
      --suffix PATH : "${
        lib.makeBinPath [
          fontconfig
          glib
          xdg-utils
        ]
      }"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/misterdownloadmanager-cli";

  meta = {
    description = "Fast, open-source multi-connection and torrent download manager";
    homepage = "https://github.com/anefzaoui/misterdownloadmanager";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "misterdownloadmanager";
  };
}
