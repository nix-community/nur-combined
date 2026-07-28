{
  bashNonInteractive,
  callPackage,
  coreutils,
  curl,
  desktop-file-utils,
  findutils,
  fontconfig,
  freetype,
  glib,
  gnugrep,
  gnused,
  gnutls,
  gtk4,
  iproute2,
  kmod,
  lib,
  libGL,
  libx11,
  libxext,
  makeWrapper,
  pango,
  patchelf,
  procps,
  python3,
  source ? (callPackage ../../_sources/generated.nix { }).radmin-vpn,
  squashfsTools,
  stdenv,
  stdenvNoCC,
  sudo,
  withChatFix ? false,
  withFilterUi ? false,
}:

let
  version = lib.removePrefix "v" source.version;

  runtimePath = lib.makeBinPath (
    [
      bashNonInteractive
      coreutils
      curl
      findutils
      gnugrep
      gnused
      iproute2
      kmod
      procps
      sudo
    ]
    ++ lib.optional withChatFix python3
  );

  runtimeLibraryPath = lib.makeLibraryPath (
    [
      fontconfig
      freetype
      gnutls
      libGL
      stdenv.cc.libc
      stdenv.cc.cc.lib
      libx11
      libxext
    ]
    ++ lib.optionals withFilterUi [
      glib
      gtk4
      pango
    ]
  );

  patchedAppImage = stdenv.mkDerivation {
    pname = "radmin-vpn-appimage";
    inherit version;
    src = source.src;

    dontUnpack = true;
    dontPatchELF = true;
    dontStrip = true;
    strictDeps = true;

    nativeBuildInputs = [
      patchelf
      squashfsTools
    ];

    buildPhase = ''
      runHook preBuild

      cp "$src" upstream.AppImage
      chmod +x upstream.AppImage
      appImageOffset=$(./upstream.AppImage --appimage-offset)
      ./upstream.AppImage --appimage-extract >/dev/null
      chmod -R u+w squashfs-root

      patch -p1 \
        -d squashfs-root/usr/bin \
        < ${./optional-python.patch}
      patch -p1 \
        -d squashfs-root/usr/bin \
        < ${./restrict-netsh-relay.patch}

      for executable in \
        squashfs-root/wine/bin/wine \
        squashfs-root/wine/bin/wineserver \
        squashfs-root/wine/lib/wine/x86_64-unix/wine \
        squashfs-root/usr/lib/radmin-vpn/rvpn_filter_ui
      do
        patchelf \
          --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
          "$executable"
      done

      head -c "$appImageOffset" upstream.AppImage > patched.AppImage
      mksquashfs \
        squashfs-root \
        filesystem.squashfs \
        -comp zstd \
        -b 131072 \
        -noappend \
        -no-tailends \
        -all-root \
        -quiet
      cat filesystem.squashfs >> patched.AppImage
      chmod +x patched.AppImage

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp patched.AppImage "$out"
      runHook postInstall
    '';
  };
in
stdenvNoCC.mkDerivation {
  pname = "radmin-vpn";
  inherit version;

  dontUnpack = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;
  strictDeps = true;

  nativeBuildInputs = [
    desktop-file-utils
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 \
      ${patchedAppImage} \
      "$out/libexec/radmin-vpn/RadminVPN-Linux-x86_64.AppImage"

    makeWrapper \
      "$out/libexec/radmin-vpn/RadminVPN-Linux-x86_64.AppImage" \
      "$out/bin/radmin-vpn" \
      --prefix PATH : "${runtimePath}" \
      --prefix LD_LIBRARY_PATH : \
        "${runtimeLibraryPath}:/run/opengl-driver/lib"

    mkdir appimage
    cd appimage
    ${patchedAppImage} --appimage-extract radmin-vpn.desktop >/dev/null
    ${patchedAppImage} --appimage-extract radmin-vpn.png >/dev/null
    substituteInPlace squashfs-root/radmin-vpn.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=radmin-vpn'
    install -Dm644 \
      squashfs-root/radmin-vpn.desktop \
      "$out/share/applications/radmin-vpn.desktop"
    install -Dm644 \
      squashfs-root/radmin-vpn.png \
      "$out/share/icons/hicolor/256x256/apps/radmin-vpn.png"
    desktop-file-validate "$out/share/applications/radmin-vpn.desktop"

    runHook postInstall
  '';

  meta = {
    description = "Run Radmin VPN on Linux through Wine and a TAP bridge";
    homepage = "https://github.com/baptisterajaut/radmin-vpn-linux";
    changelog = "https://github.com/baptisterajaut/radmin-vpn-linux/releases/tag/${source.version}";
    license = with lib.licenses; [
      gpl3Only
      lgpl21Plus
    ];
    mainProgram = "radmin-vpn";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };

  passthru = {
    inherit withChatFix withFilterUi;
  };
}
