{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  gtk3,
  libayatana-appindicator,
  gdk-pixbuf,
  glib,
  xorg,
  pkg-config,
  makeWrapper,
  wireguard-tools,
  openresolv,
}:
buildGoModule {
  pname = "wireguird";
  version = "unstable-2025-09-04";

  src = fetchFromGitHub {
    owner = "UnnoTed";
    repo = "wireguird";
    rev = "6dac3cd8784118f4fe7ea6d544a583c26d589572";
    sha256 = "sha256-iv0/HSu/6IOVmRZcyCazLdJyyBsu5PyTajLubk0speI=";
  };
  proxyVendor = true;

  vendorHash = "sha256-h58LXLjlriZJEcKn0K0QiPv+Yfbw0zQQBgMQoFL70UY=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    gtk3
    libayatana-appindicator
    gdk-pixbuf
    glib
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
  ];

  postPatch = ''
    go version
    substituteInPlace gui/gui.go \
      --replace-fail 'IconPath    = "/opt/wireguird/Icon/"' \
                     'IconPath    = "/run/current-system/sw/share/wireguird/Icon/"'
    substituteInPlace wireguird.glade \
      --replace-fail '/opt/wireguird/Icon/' \
                     '/run/current-system/sw/share/wireguird/Icon/'
  '';

  postInstall = ''
    mkdir -p "$out/share/wireguird/Icon"
    cp -r Icon/* "$out/share/wireguird/Icon/"

    # hicolor theme (so Icon=wireguird works from the desktop file)
    for sz in 16x16 32x32 48x48 128x128 256x256; do
      if [ -f "Icon/$sz/wireguard.png" ]; then
        install -Dm644 "Icon/$sz/wireguard.png" \
          "$out/share/icons/hicolor/$sz/apps/wireguird.png"
      fi
    done
    if [ -f Icon/wireguard.svg ]; then
      install -Dm644 Icon/wireguard.svg \
        "$out/share/icons/hicolor/scalable/apps/wireguird.svg"
    fi

    # Desktop entry
    install -Dm644 /dev/stdin "$out/share/applications/wireguird.desktop" <<EOF
      [Desktop Entry]
      Type=Application
      Name=Wireguird
      Comment=WireGuard GUI
      Exec=pkexec $out/bin/wireguird
      Terminal=false
      Icon=wireguird
      Categories=Network;Security;
    EOF

    # Polkit policy (pkexec target must match)
    install -Dm644 /dev/stdin "$out/share/polkit-1/actions/wireguird.policy" <<EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE policyconfig PUBLIC
       "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
       "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
      <policyconfig>
        <action id="org.freedesktop.policykit.pkexec.wireguird">
          <description>Wireguard GUI</description>
          <message>Authentication is required to run wireguird</message>
          <defaults>
            <allow_any>auth_admin</allow_any>
            <allow_inactive>auth_admin</allow_inactive>
            <allow_active>auth_admin</allow_active>
          </defaults>
          <annotate key="org.freedesktop.policykit.exec.path">$out/bin/wireguird</annotate>
          <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
        </action>
      </policyconfig>
    EOF

    # Ensure wg/wg-quick & resolvconf are available at runtime.
    wrapProgram "$out/bin/wireguird" \
      --prefix PATH : ${
        lib.makeBinPath [
          wireguard-tools
          openresolv
        ]
      }
  '';

  meta = with lib; {
    description = "Wireguard GUI (Nix package with desktop entry + polkit)";
    homepage = "https://github.com/UnnoTed/wireguird";
    license = licenses.mit;
    platforms = platforms.linux;
    broken = !stdenv.hostPlatform.isLinux;
    mainProgram = "wireguird";
  };
}
