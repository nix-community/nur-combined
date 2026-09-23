{
  lib,
  callPackage,
  stdenv,
  stdenvNoCC,
  fetchurl,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  python3,
  versionCheckHook,
  alsa-lib,
  atk,
  cairo,
  cups,
  copyDesktopItems,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk2,
  harfbuzz,
  libGL,
  libX11,
  libXScrnSaver,
  libXcomposite,
  libXcursor,
  libXdamage,
  libexif,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libXtst,
  makeDesktopItem,
  nspr,
  nss,
  pango,
  udev,
  copyIcons,
  deleteUselessFiles,
  resizeIcons,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "chromium-bin";
  version = "50.0.2661.0";

  src = fetchurl {
    url = "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/${finalAttrs.passthru.revision}/chrome-linux.zip";
    hash = "sha256-dmOyIPwJ8PHQjKSN84pMMNbuQPO5RiEaf1W0Bv1dFAA=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    makeWrapper
    python3
    copyDesktopItems
    copyIcons
    resizeIcons
    deleteUselessFiles
  ];

  buildInputs = [
    alsa-lib
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    finalAttrs.passthru.gconf-shim
    gdk-pixbuf
    glib
    gtk2
    libGL
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    nspr
    nss
    pango
    stdenv.cc.cc.lib
  ];

  # Chromium 50 loads these with dlopen, so they have to be in its rpath even
  # though none of its binaries links against them
  runtimeDependencies = [
    libGL
    (lib.getLib libexif)
    (lib.getLib udev)
  ];

  # the executables and the data files have to stay in the same directory,
  # because the binaries look for resources relative to themselves
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/chromium $out/share/man/man1/
    cp -r . $out/lib/chromium
    ln -s $out/lib/chromium/chrome.1 $out/share/man/man1/chromium.1

    runHook postInstall
  '';

  # Chromium 50 shares ~/.config/chromium with current versions of Chromium by
  # default, and it refuses to run with a profile that a newer version wrote,
  # so a version specific profile is used unless the command line specifies
  # another one (Chromium uses the last occurrence of a switch).
  #
  # The setuid sandbox of Chromium 50 needs its sandbox helper to be setuid
  # root, which is impossible in the store, and Chromium refuses to start
  # without a sandbox, so it is asked to use its namespace sandbox instead.
  #
  # The seccomp-bpf policy of Chromium 50 does not know the clone3 system call,
  # which glibc uses to create threads since version 2.34 (it only reached Linux
  # in 5.3, three years after Chromium 50 was released), and it responds by
  # killing the renderer processes with SIGSYS, so the seccomp filter is
  # disabled as well.  The namespace sandbox remains in effect: the renderer
  # processes run in their own user, pid and network namespaces.
  #
  # Both of those switches are on the list of unsupported switches of Chromium,
  # for which it shows an infobar that says that stability and security will
  # suffer, on every launch.  --test-type, the switch that Chromium provides for
  # setups that are not supposed to be bothered by that infobar, suppresses it,
  # and it disables neither the namespace sandbox nor the certificate checks.
  postInstall = ''
    makeWrapper $out/lib/chromium/chrome $out/bin/chromium \
      --prefix LD_LIBRARY_PATH : $out/lib/chromium \
      --set CHROME_DESKTOP chromium.desktop \
      --add-flags '--disable-setuid-sandbox --disable-seccomp-filter-sandbox --test-type' \
      --add-flags '--user-data-dir="''${XDG_CONFIG_HOME:-$HOME/.config}/chromium-50"'
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [ versionCheckHook ];

  # Chromium 50 statically links harfbuzz and exports its symbols.  The dynamic
  # linker prefers the symbols of the executable over those of the libraries it
  # loads, so the harfbuzz that pango, which the GTK 2 user interface of Chromium
  # 50 uses, resolves its calls to would be the harfbuzz inside Chromium 50, whose
  # internal ABI is different, which crashes the browser as soon as GTK shapes
  # text.  Hiding those symbols makes pango use the harfbuzz it was built
  # against.  This has to happen after autoPatchelfHook has patched the binaries,
  # hence a post phase instead of postFixup.
  #
  # The other symbols that Chromium 50 exports and that its libraries also export
  # are the allocator functions, which Chromium overrides deliberately and whose
  # ABI does not change, so they are left alone.
  postFixup = ''
    python3 ${./hide-symbols.py} ${lib.getLib harfbuzz}/lib/libharfbuzz.so.0 \
      $out/lib/chromium/chrome \
      $out/lib/chromium/nacl_helper
  '';

  icon = "product_logo_48.png";

  desktopItems = [
    (makeDesktopItem {
      name = "chromium";
      desktopName = "Chromium 50";
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.meta.mainProgram} %U";
      icon = "chromium";
      categories = [
        "Network"
        "WebBrowser"
      ];
      startupNotify = true;
    })
  ];

  passthru.revision = "378072";
  passthru.gconf-shim = callPackage ./gconf-shim.nix { };

  meta = {
    description = "Web browser from the Chromium project, version 50 (prebuilt binary)";
    longDescription = ''
      Chromium is an open source web browser.  This package provides version 50,
      which was released in 2016, as built by the continuous build of the
      Chromium project, so that content and web applications of that era can
      still be run.  Since it is a prebuilt binary, it is not built against the
      libraries in nixpkgs.

      $out/bin/chromium runs the browser with its setuid sandbox and its
      seccomp-bpf filter disabled, because the former needs a setuid root helper
      that the store cannot provide, and the latter, which is from 2016, kills the
      renderer processes of the browser on current systems by rejecting the clone3
      system call that current C libraries use; the namespace sandbox is still in
      effect.  Both switches are on the list of unsupported switches of Chromium,
      so the wrapper also passes --test-type, which keeps Chromium from showing
      its "stability and security will suffer" warning infobar on every launch.
      Run $out/lib/chromium/chrome directly to use the browser without any of
      these switches and to see that warning, and pass --no-sandbox to disable the
      sandbox completely.
    '';
    homepage = "https://www.chromium.org/";
    downloadPage = "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/${finalAttrs.passthru.revision}/";
    changelog = "https://chromium.googlesource.com/chromium/src/+log/refs/branch-heads/2661";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "chromium";
  };
})
