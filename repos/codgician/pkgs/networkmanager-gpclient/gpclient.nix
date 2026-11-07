# gpclient and gpauth from the GlobalProtect-openconnect submodule the plugin
# pins. The service drives gpclient's command line and parses its log records,
# so both come from the same plugin revision, as upstream's packages do.
{
  lib,
  rustPlatform,
  autoconf,
  automake,
  libtool,
  makeBinaryWrapper,
  perl,
  pkg-config,
  wrapGAppsHook3,
  atk,
  cairo,
  glib,
  glib-networking,
  gmp,
  gnutls,
  gtk3,
  libxml2,
  lz4,
  nettle,
  openssl,
  p11-kit,
  pango,
  webkitgtk_4_1,
  zlib,
  coreutils,
  gawk,
  gnugrep,
  gnused,
  iproute2,
  net-tools,
  openresolv,
  pciutils,
  systemd,
  unixtools,
  src,
}:
let
  runtimePath = lib.makeBinPath [
    coreutils
    gawk
    unixtools.ps
    iproute2
    pciutils # lspci
    systemd # resolvectl, systemctl, systemd-detect-virt
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gpclient";
  # The workspace version of the submodule; postPatch fails when it moves.
  version = "3.2.0";

  inherit src;
  sourceRoot = "${src.name}/external/GlobalProtect-openconnect";

  cargoHash = "sha256-CqcGbfsIMSnCYUwvgC+jXDINJr9zaLHgc8VsOmHT1go=";

  cargoBuildFlags = [
    "--package=gpclient"
    "--package=gpauth"
  ];
  cargoTestFlags = finalAttrs.cargoBuildFlags;

  nativeBuildInputs = [
    makeBinaryWrapper
    perl
    pkg-config
    wrapGAppsHook3

    # used to build vendored openconnect
    autoconf
    automake
    libtool
  ];

  buildInputs = [
    atk
    cairo
    glib
    glib-networking
    gmp
    gnutls
    gtk3
    pango
    webkitgtk_4_1

    # used for vendored openconnect
    libxml2
    lz4
    nettle
    openssl
    p11-kit
    zlib
  ];

  # The test runs the collector with PATH=…:/usr/bin:/bin, so it needs an FHS
  # system; installed, gpclient's wrapper provides the collector's tools.
  checkFlags = [
    "--skip=embedded_collector_reports_missing_helpers_without_recursing_or_exposing_private_environment"
  ];

  # gpclient finds gpauth next to itself and vpnc-script in ../libexec/gpclient,
  # so the binaries need no path patches.
  postPatch = ''
    grep -qx 'version = "${finalAttrs.version}"' Cargo.toml || {
      echo "gpclient: the submodule is not version ${finalAttrs.version}" >&2
      exit 1
    }
  '';

  postInstall = ''
    install -Dm755 packaging/files/usr/libexec/gpclient/vpnc-script \
      $out/libexec/gpclient/vpnc-script
    substituteInPlace $out/libexec/gpclient/vpnc-script \
      --replace-fail /sbin/resolvconf ${openresolv}/bin/resolvconf \
      --replace-fail /usr/bin/resolvectl ${systemd}/bin/resolvectl \
      --replace-fail /usr/bin/busctl ${systemd}/bin/busctl
    wrapProgram $out/libexec/gpclient/vpnc-script \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gawk
          gnugrep
          gnused
          iproute2
          net-tools
          openresolv
          unixtools.ps
        ]
      }

    # The globalprotectcallback handler gpauth registers for external browsers
    install -Dm644 packaging/files/usr/share/applications/gpgui.desktop \
      $out/share/applications/gpgui.desktop
    substituteInPlace $out/share/applications/gpgui.desktop \
      --replace-fail /usr/bin/gpclient $out/bin/gpclient
  '';

  # gpauth shows the SAML page in WebKitGTK; gpclient runs as root.
  dontWrapGApps = true;

  postFixup = ''
    wrapProgram $out/bin/gpauth "''${gappsWrapperArgs[@]}"
    # Collectors use GP_COMMAND_PATH instead of PATH.
    wrapProgram $out/bin/gpclient \
      --prefix PATH : ${runtimePath} \
      --prefix GP_COMMAND_PATH : ${runtimePath} \
      --prefix GIO_EXTRA_MODULES : ${glib-networking}/lib/gio/modules
  '';

  meta = {
    description = "GlobalProtect VPN client (gpclient and gpauth) bundled with networkmanager-gpclient";
    homepage = "https://github.com/yuezk/GlobalProtect-openconnect";
    license = lib.licenses.gpl3Only;
    mainProgram = "gpclient";
    platforms = lib.platforms.linux;
  };
})
