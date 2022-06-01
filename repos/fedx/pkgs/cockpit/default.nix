{ lib, stdenv, fetchFromGitHub, pkgconfig, glib, systemd, json-glib, gnutls, krb5, polkit, libssh, pam, libxslt, xmlto
, python3, gnused, coreutils, makeWrapper, openssl
, packages ? []
, client ? false, python3Packages, wrapGAppsHook, gtk3, gobject-introspection, webkitgtk, glib-networking, openssh }:

let
  path = lib.makeSearchPath "bin" ([ "$out" "/run/wrappers" "/run/current-system/sw" ] ++ packages);
in stdenv.mkDerivation rec {
  pname = "cockpit";
  version = "270";

  src = fetchFromGitHub {
    owner = "cockpit-project";
    repo = pname;
    rev = version;
    sha256 = "sha256-LzPwuYBC2HukgsCtWPyCJkJX8gwe0Fg4ARqSPy2HB7U=";
  };

  configureFlags = [
    "--disable-pcp"
    "--disable-doc"
    "--with-systemdunitdir=$(out)/lib/systemd/system"
    "--sysconfdir=/etc"
  ] ++ lib.optionals client [
    "--enable-cockpit-client"
  ];

  nativeBuildInputs = [
    pkgconfig python3 gnused makeWrapper
  ] ++ lib.optionals client [
    python3Packages.wrapPython wrapGAppsHook gobject-introspection
  ];

  buildInputs = [
    glib systemd json-glib gnutls krb5 polkit libssh pam libxslt xmlto
  ] ++ lib.optionals client [
    gtk3 webkitgtk glib-networking
  ];

  postPatch = ''
    patchShebangs tools
    sed -r '/^cmd_make_package_lock_json\b/ a exit 0' -i tools/node-modules
    substituteInPlace Makefile.in \
      --replace "\$(DESTDIR)\$(sysconfdir)" "$out/etc"
    substituteInPlace src/session/session-utils.h \
      --replace "DEFAULT_PATH \"" "DEFAULT_PATH \"${path}:"
  '' + lib.optionalString client ''
    substituteInPlace src/client/cockpit-client \
      --replace "or options.lookup_value('wildly-insecure')" "or True"
    substituteInPlace src/client/cockpit-client-ssh \
      --replace "shutil.copy(__file__, askpass, follow_symlinks=False)" "shutil.copy(__file__, askpass, follow_symlinks=False);os.chmod(askpass, 0o755);" \
      --replace "'flatpak-spawn', '--host', '/usr/bin/env'" "'${coreutils}/bin/env'" \
      --replace "/usr/bin/ssh" "${openssh}/bin/ssh"
  '';

  postInstall = ''
    wrapProgram "$out/libexec/cockpit-certificate-helper" \
      --suffix PATH : "${lib.makeBinPath [ coreutils openssl ]}"
  '' + lib.optionalString client ''
    patchShebangs $out/libexec
  '';

  dontWrapGApps = true;
  preFixup = lib.optionalString client ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';
  pythonPath = with python3Packages; [ pygobject3 ];
  postFixup = lib.optionalString client ''
    wrapPythonProgramsIn $out/libexec "$out $pythonPath"
  '';

  meta = with lib; {
    description = "Web-based graphical interface for servers";
    license = licenses.lgpl21;
    homepage = "https://cockpit-project.org/";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
    broken = true;
  };
}
