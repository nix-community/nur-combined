{
  lib,
  stdenv,
  autoPatchelfHook,
  dpkg,
  makeBinaryWrapper,
  requireFile,
  qt5,
  wayland,
  libglvnd,
  xkeyboard_config,
  xorg,
  libjpeg_turbo,
  libwebp,
  freetype,
  fontconfig,
  notoFontsCjk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zw3d";
  version = "2026.0.1.0";

  src = requireFile rec {
    name = "signed_com.zwsoft.zw3d2026_${finalAttrs.version}_amd64.deb";
    hash = "sha256-PgCQwF8ZJU1GjxMkZem5BEAifO9qaiYeVxBOnRdvAtg=";
    message = ''
      ZW3D is proprietary and the download is blocked for automated fetches.
      Please download the .deb from:

        https://www.zwsoft.cn/product/zw3d/linux

      Choose the download for: 统信UOSV20/深度V20 (x86_64).

      Then run:

        nix-prefetch-url file://$PWD/${name}

      And replace the hash in pkgs/zw3d/default.nix.
    '';
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeBinaryWrapper
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtwayland
    wayland
    libglvnd
    stdenv.cc.cc.lib
    xorg.libX11
    xorg.libXmu
    xorg.libXt
    libjpeg_turbo
    libwebp
    freetype
    fontconfig
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    shopt -s nullglob
    for dir in opt usr etc; do
      if [ -e "$dir" ]; then
        cp -a "$dir" "$out/"
      fi
    done

    # Remove bundled libs to prefer system libraries.
    find "$out" -name "libfreetype.so*" -path "*/lib3rd/*" -delete || true

    while IFS= read -r -d $'\\0' lib; do
      rm -f "$lib"
      ln -s ${libwebp}/lib/libwebp.so "$lib"
    done < <(find "$out" -name "libwebp.so.6" -print0 || true)

    # Provide the font expected by absolute path in the app.
    fontSrc="$(find ${notoFontsCjk}/share/fonts -type f \
      -name 'NotoSansCJK-Regular.ttc' -o -name 'NotoSansCJK-VF.otf.ttc' | head -n1)"
    test -n "$fontSrc" || (echo "Noto CJK font not found in ${notoFontsCjk}" >&2; exit 1)
    mkdir -p "$out/usr/share/fonts/opentype/noto"
    ln -s "$fontSrc" "$out/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"

    # Create a wrapper if a main binary is present.
    bin="$(find "$out" -type f -executable -name 'ZW3D' -o -name 'zw3d' | head -n1)"
    test -n "$bin" || (echo "ZW3D binary not found in extracted .deb" >&2; exit 1)
    lib3rd="$(find "$out" -type d -name lib3rd | head -n1)"
    wrapperArgs=()
    test -n "$lib3rd" && wrapperArgs+=(--prefix LD_LIBRARY_PATH : "$lib3rd")
    mkdir -p "$out/bin"
    wrapperArgs+=(
      --set QTCOMPOSE ${xorg.libX11.out}/share/X11/locale
      --set QT_XKB_CONFIG_ROOT ${xkeyboard_config}/share/X11/xkb
      --set XKB_CONFIG_ROOT ${xkeyboard_config}/share/X11/xkb
    )
    makeWrapper "$bin" "$out/bin/zw3d" "''${wrapperArgs[@]}"

    runHook postInstall
  '';

  dontWrapQtApps = true;
  autoPatchelfIgnoreMissingDeps = true;
  dontStrip = true;

  meta = {
    description = "ZW3D proprietary CAD software";
    homepage = "https://www.zwsoft.cn/product/zw3d/linux";
    license = lib.licenses.unfree;
    mainProgram = "zw3d";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
