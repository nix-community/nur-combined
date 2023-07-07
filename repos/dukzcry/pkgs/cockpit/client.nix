{ lib, stdenv, fetchzip, pkg-config, glib, systemd, json-glib, gnutls, krb5, pam, libxcrypt, python3
, python3Packages, wrapGAppsHook, gobject-introspection, webkitgtk, coreutils, openssh, getent }:

stdenv.mkDerivation rec {
  pname = "cockpit-client";
  version = "292";
  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit/releases/download/${version}/cockpit-${version}.tar.xz";
    sha256 = "sha256-BDcYMwLUCgQxhaPj+tt8IRVwQpG1A6lNzm61WX+6LnY=";
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
    pkg-config python3 python3Packages.wrapPython wrapGAppsHook gobject-introspection getent
  ];
  buildInputs = [
    glib systemd json-glib gnutls krb5 pam libxcrypt webkitgtk
  ];
  postPatch = ''
    substituteInPlace src/client/cockpit-client \
      --replace "or options.lookup_value('wildly-insecure')" "or True"
    substituteInPlace src/client/cockpit-client-ssh \
      --replace "'flatpak-spawn', '--host', '/usr/bin/env'" "'${coreutils}/bin/env'" \
      --replace "shutil.copy(__file__, askpass, follow_symlinks=False)" "shutil.copy(__file__, askpass, follow_symlinks=False); os.chmod(askpass, 0o755);" \
      --replace "/usr/bin/ssh" "${openssh}/bin/ssh"
  '';
  preBuild = ''
    patchShebangs tools
  '';
  postInstall = ''
    patchShebangs $out/libexec
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
