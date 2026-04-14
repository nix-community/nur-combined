{ lib
, appimageTools
, fetchurl
, runCommand
, stdenv
, mesa
, vips
}:

let
  pname = "flow-browser-bin";
  version = "0.8.6";

  # Flow bundles `sharp`, which attempts to dlopen libvips with a filename that
  # includes the libvips version (e.g. libvips-cpp.so.8.17.3). Nixpkgs provides
  # libvips with a different SONAME-based filename (e.g. libvips-cpp.so.42.19.3),
  # so we provide compatibility symlinks in the FHS env.
  vipsSharpCompat = runCommand "flow-browser-vips-compat" { } ''
    mkdir -p $out/lib
    # Link to the SONAME symlinks provided by nixpkgs, so we don't hardcode the
    # 42.x.y patchlevel.
    ln -sf ${vips.out}/lib/libvips-cpp.so.42 $out/lib/libvips-cpp.so.8
    ln -sf ${vips.out}/lib/libvips.so.42 $out/lib/libvips.so.8

    # `sharp` wants an exact libvips filename including patchlevel (observed in
    # Flow 0.8.6: libvips-cpp.so.8.17.3). Provide a small compatibility set:
    # - the version bundled with Flow (`8.17.3`)
    # - the current nixpkgs vips.version (helps when they match)
    for v in 8.17.3 ${vips.version}; do
      ln -sf ${vips.out}/lib/libvips-cpp.so.42 $out/lib/libvips-cpp.so.$v
      ln -sf ${vips.out}/lib/libvips.so.42 $out/lib/libvips.so.$v
    done
  '';

  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "https://github.com/MultiboxLabs/flow-browser/releases/download/v${version}/flow-browser-${version}-x86_64.AppImage";
        sha256 = "1s4i419vlwgqzy8p73msb6djf6bbdk530inwc6hr7rwz611cf0gz";
      }
    else if stdenv.hostPlatform.system == "aarch64-linux" then
      fetchurl {
        url = "https://github.com/MultiboxLabs/flow-browser/releases/download/v${version}/flow-browser-${version}-arm64.AppImage";
        sha256 = "0n2cp0519z43z5aa6mc7xzrhp6mpfjl7fkls29hk6db4mzv6sfsn";
      }
    else
      throw "flow-browser-bin: unsupported system: ${stdenv.hostPlatform.system}";

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = _pkgs: [
    vipsSharpCompat
    mesa
  ];

  # Ensure `sharp` can find libvips in the bubblewrapped FHS env.
  # (Relying on /usr/lib64 + ld.so cache can be flaky depending on the env.)
  profile = ''
    export LD_LIBRARY_PATH="${vipsSharpCompat}/lib''${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH"

    # Help Electron/ANGLE find GL/EGL drivers inside the FHS env.
    export LIBGL_DRIVERS_PATH="${mesa}/lib/dri"
    export __EGL_VENDOR_LIBRARY_DIRS="${mesa}/share/glvnd/egl_vendor.d''${__EGL_VENDOR_LIBRARY_DIRS:+:}$__EGL_VENDOR_LIBRARY_DIRS"
  '';

  extraInstallCommands = ''
    # Desktop entry
    install -D -m 444 ${appimageContents}/Flow.desktop \
      $out/share/applications/flow-browser.desktop

    substituteInPlace $out/share/applications/flow-browser.desktop \
      --replace-fail 'Exec=AppRun' "Exec=$out/bin/${pname}"

    # Help launchers detect the binary without relying on PATH.
    if grep -q '^TryExec=' $out/share/applications/flow-browser.desktop; then
      sed -i "s|^TryExec=.*|TryExec=$out/bin/${pname}|" $out/share/applications/flow-browser.desktop
    else
      echo "TryExec=$out/bin/${pname}" >> $out/share/applications/flow-browser.desktop
    fi

    # appimageTools.wrapType2 tends to name the wrapper with the version suffix
    # (e.g. flow-browser-bin-0.8.6). Provide a stable name for launchers/scripts.
    if [ -e "$out/bin/${pname}-${version}" ] && [ ! -e "$out/bin/${pname}" ]; then
      ln -s "$out/bin/${pname}-${version}" "$out/bin/${pname}"
    fi

    # Keep the launcher name stable (avoid showing version suffixes in menus).
    if grep -q '^Name=' $out/share/applications/flow-browser.desktop; then
      sed -i 's/^Name=.*/Name=Flow/' $out/share/applications/flow-browser.desktop
    else
      echo 'Name=Flow' >> $out/share/applications/flow-browser.desktop
    fi

    # Icon
    install -D -m 444 ${appimageContents}/usr/share/icons/hicolor/512x512/apps/Flow.png \
      $out/share/icons/hicolor/512x512/apps/flow-browser.png

    substituteInPlace $out/share/applications/flow-browser.desktop \
      --replace-fail 'Icon=Flow' 'Icon=flow-browser'
  '';

  meta = {
    description = "A modern, privacy-focused browser with a minimalistic design (binary AppImage)";
    homepage = "https://github.com/multiboxlabs/flow-browser";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "flow-browser-bin";
  };
}


