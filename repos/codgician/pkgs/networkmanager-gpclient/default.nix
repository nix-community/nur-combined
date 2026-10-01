{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  makeWrapper,
  wrapGAppsHook3,
  gobject-introspection,
  python3,
  gpclient,
  glib,
  gtk3,
  gtk4,
  libnma,
  networkmanager,
  kdePackages,
  coreutils,
  gnugrep,
  gnused,
  procps,
  iproute2,
  systemd,
  util-linux,
  xdg-utils,
  bash,
}:
let
  python = python3.withPackages (ps: [
    ps.sdbus
    ps.pygobject3
  ]);
  runtimePath = lib.makeBinPath [
    gpclient
    coreutils
    gnugrep
    gnused
    procps
    iproute2
    networkmanager
    systemd
    util-linux
    xdg-utils
    bash
  ];
  plasma = kdePackages.plasma-nm;
  pluginDir = "${kdePackages.qtbase.qtPluginPrefix}/plasma/network/vpn";
in
stdenv.mkDerivation {
  pname = "networkmanager-gpclient";
  version = "1.4.2-unstable-2026-09-30";

  src = fetchFromGitHub {
    owner = "WMP";
    repo = "GlobalProtect-SAML-NetworkManager";
    rev = "7302987f1bf5626df8aebe533adf3ea47dd25b5d";
    hash = "sha256-jg/ohuagCECF2zq+zAGBnCj+nCtdd4R1RZVWW12O1qg=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
    wrapGAppsHook3
    gobject-introspection
    kdePackages.extra-cmake-modules
  ];
  buildInputs = [
    glib
    gtk3
    gtk4
    (libnma.override { withGtk4 = true; })
    networkmanager
    kdePackages.qtbase
    kdePackages.ki18n
    kdePackages.kservice
    kdePackages.kwidgetsaddons
    kdePackages.kcoreaddons
    kdePackages.networkmanager-qt
    plasma
  ];

  dontWrapGApps = true;
  dontWrapQtApps = true;

  # These paths are literals upstream, not environment-configurable. Keep the
  # necessary Nix substitutions here rather than changing the upstream checkout.
  postPatch = ''
    substituteInPlace service/nm-gpclient-service.py \
      --replace-fail '#!/usr/bin/env python3' '#!${python}/bin/python3' \
      --replace-fail /usr/bin/gpclient ${gpclient}/bin/gpclient \
      --replace-fail /usr/libexec/gpclient/browser-wrapper "$out/libexec/gpclient/browser-wrapper" \
      --replace-fail /usr/libexec/gpclient/edge-wrapper "$out/libexec/gpclient/edge-wrapper" \
      --replace-fail /usr/bin/microsoft-edge /run/current-system/sw/bin/microsoft-edge
    substituteInPlace auth-dialog/nm-gpclient-auth-dialog.py \
      --replace-fail '#!/usr/bin/env python3' '#!${python}/bin/python3'
    substituteInPlace scripts/browser-wrapper.sh \
      --replace-fail /usr/bin/microsoft-edge /run/current-system/sw/bin/microsoft-edge \
      --replace-fail 'exec sudo ' 'exec /run/wrappers/bin/sudo '
    substituteInPlace scripts/edge-wrapper.sh \
      --replace-fail /usr/libexec/gpclient/browser-wrapper "$out/libexec/gpclient/browser-wrapper" \
      --replace-fail /usr/bin/microsoft-edge /run/current-system/sw/bin/microsoft-edge
  '';

  configurePhase = ''
    runHook preConfigure
    cmake -S plugins/plasma -B build \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$out" \
      -DQT_MAJOR_VERSION=6 \
      -DKDE_INSTALL_PLUGINDIR="$out/${kdePackages.qtbase.qtPluginPrefix}" \
      -DPLASMANM_INTERNAL=${lib.getLib plasma}/lib/libplasmanm_internal.so \
      -DPLASMANM_EDITOR=${lib.getLib plasma}/lib/libplasmanm_editor.so
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    make -C plugins/gnome -j"$NIX_BUILD_CORES" CC="$CC" all
    cmake --build build --parallel "$NIX_BUILD_CORES"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cmake --install build
    install -Dm755 service/nm-gpclient-service.py "$out/lib/NetworkManager/nm-gpclient-service"
    install -Dm755 auth-dialog/nm-gpclient-auth-dialog.py "$out/libexec/nm-gpclient-auth-dialog"
    install -Dm755 scripts/browser-wrapper.sh "$out/libexec/gpclient/browser-wrapper"
    install -Dm755 scripts/edge-wrapper.sh "$out/libexec/gpclient/edge-wrapper"
    install -Dm755 config/90-gpclient-routing "$out/libexec/gpclient/90-gpclient-routing"
    install -Dm644 config/nm-gpclient.conf "$out/share/dbus-1/system.d/nm-gpclient.conf"
    install -Dm644 plugins/gnome/nm-gpclient-service.name "$out/lib/NetworkManager/VPN/nm-gpclient-service.name"
    install -m644 plugins/gnome/*.so "$out/lib/NetworkManager/"
    ln -s NetworkManager/libnm-vpn-plugin-gpclient-editor.so "$out/lib/libnm-gpclient-properties"
    substituteInPlace "$out/lib/NetworkManager/VPN/nm-gpclient-service.name" \
      --replace-fail /usr/lib/NetworkManager/nm-gpclient-service "$out/lib/NetworkManager/nm-gpclient-service" \
      --replace-fail /usr/libexec/nm-gpclient-auth-dialog "$out/libexec/nm-gpclient-auth-dialog" \
      --replace-fail 'plugin=libnm-vpn-plugin-gpclient.so' "plugin=$out/lib/NetworkManager/libnm-vpn-plugin-gpclient.so" \
      --replace-fail 'properties=libnm-gpclient-properties' "properties=$out/lib/libnm-gpclient-properties"

    mkdir -p "$out/share/dbus-1/system-services" "$out/lib/systemd/system"
    cat > "$out/share/dbus-1/system-services/org.freedesktop.NetworkManager.gpclient.service" <<EOF
    [D-BUS Service]
    Name=org.freedesktop.NetworkManager.gpclient
    Exec=$out/lib/NetworkManager/nm-gpclient-service --persist
    User=root
    SystemdService=nm-gpclient.service
    EOF
    cat > "$out/lib/systemd/system/nm-gpclient.service" <<EOF
    [Unit]
    Description=NetworkManager GlobalProtect VPN service
    After=network.target

    [Service]
    Type=dbus
    BusName=org.freedesktop.NetworkManager.gpclient
    ExecStart=$out/lib/NetworkManager/nm-gpclient-service --persist
    User=root
    Restart=on-failure
    RuntimeDirectory=nm-gpclient
    RuntimeDirectoryMode=0700

    [Install]
    WantedBy=multi-user.target
    EOF
    runHook postInstall
  '';

  preFixup = ''
    wrapProgram "$out/lib/NetworkManager/nm-gpclient-service" --prefix PATH : '${runtimePath}'
    wrapProgram "$out/libexec/nm-gpclient-auth-dialog" "''${gappsWrapperArgs[@]}"
    wrapProgram "$out/libexec/gpclient/browser-wrapper" --prefix PATH : '${runtimePath}'
  '';

  passthru = {
    networkManagerPlugin = "VPN/nm-gpclient-service.name";
    plasmaPlugin = "${pluginDir}/plasmanetworkmanagement_gpclientui.so";
    routingHook = "libexec/gpclient/90-gpclient-routing";
    inherit gpclient;
  };

  meta = {
    description = "NetworkManager GlobalProtect VPN plugin with SAML authentication and Plasma 6 editor";
    homepage = "https://github.com/WMP/GlobalProtect-SAML-NetworkManager";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
  };
}
