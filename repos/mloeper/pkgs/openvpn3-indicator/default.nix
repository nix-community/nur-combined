{ python311Packages
, fetchFromGitHub
, openvpn3
, lib
, libayatana-appindicator
, libappindicator-gtk3
, gobject-introspection
, wrapGAppsHook
}:
python311Packages.buildPythonPackage {
  name = "openvpn3-indicator";
  src = fetchFromGitHub {
    owner = "OpenVPN";
    repo = "openvpn3-indicator";
    rev = "177f15a2cd87d047e37e7d3a51338bfbdd817e56";
    hash = "sha256-22SZHrsihcDDoo2yfvDumiAh0ddWE2aX8eoegOOMA+g=";
  };
  dependencies = with python311Packages; [
    setuptools
    secretstorage
    dbus-python
    pygobject3
    setproctitle
    openvpn3
  ];
  propagatedBuildInputs = with python311Packages; [
    setuptools
    secretstorage
    dbus-python
    pygobject3
    setproctitle
    openvpn3
  ];
  buildInputs = [
    # Adds AppIndicator3 namespace
    libappindicator-gtk3
    # Adds AyatanaAppIndicator3 namespace
    libayatana-appindicator
  ];
  nativeBuildInputs = [
    # Needed for the NM namespace
    gobject-introspection
    wrapGAppsHook
  ];
  patches = [
    ./patches/001-add-setup-py.patch
  ];
  postInstall = ''
    cp -r $src/share $out/share

    substituteInPlace $out/share/applications/net.openvpn.openvpn3_indicator.desktop --replace "/usr/bin/openvpn3-indicator" "openvpn3-indicator"
  '';
  meta = {
    description = "Simple GTK indicator GUI for OpenVPN 3 Linux";
    homepage = "https://github.com/OpenVPN/openvpn3-indicator";
    license = lib.licenses.gpl3;
    mainProgram = "openvpn3-indicator";
  };
}
