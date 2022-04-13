{ lib, stdenv, fetchzip, pkgconfig, glib, systemd, json-glib, gnutls, krb5, polkit, libssh, pam, libxslt, xmlto
, python3, gnused, coreutils, makeWrapper, openssl }:

stdenv.mkDerivation rec {
  pname = "cockpit";
  version = "267";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit/releases/download/${version}/cockpit-${version}.tar.xz";
    sha256 = "0bdc2qzqcz4k92asxip00nambn47a4w12c4vl08xj6nc1ja627ig";
  };

  configureFlags = [
    "--disable-pcp"
    "--disable-doc"
    "--with-systemdunitdir=$(out)/lib/systemd/system"
    "--sysconfdir=/etc"
  ];

  nativeBuildInputs = [
    pkgconfig python3 gnused makeWrapper
  ];

  buildInputs = [
    glib systemd json-glib gnutls krb5 polkit libssh pam libxslt xmlto
  ];

  postPatch = ''
    patchShebangs tools
    sed -r '/^cmd_make_package_lock_json\b/ a exit 0' -i tools/node-modules
    substituteInPlace Makefile.in \
      --replace "\$(DESTDIR)\$(sysconfdir)" "$out/etc"
    substituteInPlace src/session/session-utils.h \
      --replace "DEFAULT_PATH \"" "DEFAULT_PATH \"$out/bin:/run/current-system/sw/bin:"
  '';

  postInstall = ''
    wrapProgram "$out/libexec/cockpit-certificate-helper" \
      --suffix PATH : "${lib.makeBinPath [ coreutils openssl ]}"
  '';

  meta = with lib; {
    description = "Web-based graphical interface for servers";
    license = licenses.lgpl21;
    homepage = "https://cockpit-project.org/";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
