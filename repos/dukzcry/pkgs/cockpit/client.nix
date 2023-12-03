{ lib, stdenv, fetchzip, pkg-config, glib, systemd, json-glib, gnutls, krb5, pam, libxcrypt, python3
, python3Packages, wrapGAppsHook, gobject-introspection, webkitgtk, coreutils, openssh, getent }:

stdenv.mkDerivation rec {
  pname = "cockpit-client";
  version = "306";
  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit/releases/download/${version}/cockpit-${version}.tar.xz";
    sha256 = "sha256-xRMCvsFTUCyPcNuy8/e3Zg2ptc9GbK5pOGcL7g7FJ50=";
  };
  enableParallelBuilding = true;
  configureFlags = [
    "--disable-polkit"
    "--disable-ssh"
    "--disable-pcp"
    "--disable-doc"
    "--enable-cockpit-client"
    "--with-systemdunitdir=$(out)/lib/systemd/system"
  ];
  nativeBuildInputs = [
    pkg-config python3 wrapGAppsHook gobject-introspection getent
  ] ++ (with python3Packages; [
    wrapPython pip
  ]);
  buildInputs = [
    glib systemd json-glib gnutls krb5 pam libxcrypt webkitgtk
  ];
  postPatch = ''
    substituteInPlace src/client/cockpit-client \
      --replace "or options.lookup_value('wildly-insecure')" "or True"
    substituteInPlace src/cockpit/packages.py \
      --replace "/usr/local/libexec" "$out/libexec"
    substituteInPlace src/cockpit/beiboot.py \
      --replace "python3" "${python3}/bin/python3"
  '';
  preBuild = ''
    patchShebangs tools
  '';
  postInstall = ''
    patchShebangs $out/libexec
cat << EOF > $out/libexec/cockpit-beiboot
#!/bin/sh
export PYTHONPATH=$(echo $out/lib/python*/site-packages)
export LD_LIBRARY_PATH=${systemd}/lib
/usr/bin/env python3 -m cockpit.beiboot "\$@"
EOF
    chmod +x $out/libexec/cockpit-beiboot
    substituteInPlace $out/libexec/cockpit-client \
      --replace "/usr/bin/env python3 -m cockpit.beiboot" "$out/libexec/cockpit-beiboot"
  '';
  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';
  pythonPath = with python3Packages; [ pygobject3 ];
  postFixup = ''
    wrapPythonProgramsIn $out/libexec "$out $pythonPath"
  '';
  meta = with lib; {
    description = "GUI for Cockpit";
    license = licenses.lgpl21;
    homepage = "https://cockpit-project.org/";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
