{
  sources,
  lib,
  stdenv,
  buildFHSEnv,
  runCommand,
  binutils,
  gnutar,
  # Dependencies
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  glib,
  gnome2,
  gtk3,
  libdrm,
  libgbm,
  libGLU,
  libglvnd,
  libva,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  rtmpdump,
  udev,
  vulkan-loader,
  libICE,
  libSM,
  libX11,
  libxcb,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXinerama,
  libXmu,
  libXrandr,
  libXrender,
  libXScrnSaver,
  libXt,
  libXtst,
  xcbutilimage,
  xcbutilkeysyms,
  xcbutilrenderutil,
  xcbutilwm,
}:
let
  libraries = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    glib
    gnome2.gtkglext
    gtk3
    libdrm
    libgbm
    libGLU
    libglvnd
    libva
    libxkbcommon
    mesa
    nspr
    nss
    pango
    rtmpdump
    udev
    vulkan-loader
    libICE
    libSM
    libX11
    libxcb
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXinerama
    libXmu
    libXrandr
    libXrender
    libXScrnSaver
    libXt
    libXtst
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
  ];

  distPkg =
    runCommand "adspower-dist"
      {
        nativeBuildInputs = [
          binutils
          gnutar
        ];
      }
      ''
        mkdir -p $out
        ar x ${sources.adspower.src}
        tar xf data.tar.xz -C $out
      '';

  fhs = buildFHSEnv {
    name = sources.adspower.pname;
    targetPkgs = _pkgs: libraries;
    runScript = "${distPkg}/opt/AdsPower\\ Global/adspower_global";

    unshareUser = false;
    unshareIpc = false;
    unsharePid = false;
    unshareNet = false;
    unshareUts = false;
    unshareCgroup = false;
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.adspower) pname version;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 ${fhs}/bin/${finalAttrs.pname} $out/bin/${finalAttrs.pname}
    install -Dm644 ${distPkg}/usr/share/applications/adspower_global.desktop $out/share/applications/adspower_global.desktop
    substituteInPlace $out/share/applications/adspower_global.desktop \
      --replace-fail '"/opt/AdsPower Global/adspower_global"' "$out/bin/${finalAttrs.pname}"

    cp -r ${distPkg}/usr/share/icons $out/share/icons

    runHook postInstall
  '';

  passthru = { inherit (finalAttrs) distPkg; };

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Antidetect Browser for Multi-Accounts";
    homepage = "https://www.adspower.com/";
    platforms = [
      "x86_64-linux"
    ];
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "adspower";
  };
})
