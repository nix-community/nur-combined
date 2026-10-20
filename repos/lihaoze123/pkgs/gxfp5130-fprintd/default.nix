{ lib
, stdenv
, fetchFromGitLab
, pkg-config
, gobject-introspection
, meson
, ninja
, perl
, gettext
, gtk-doc
, libxslt
, docbook-xsl-nons
, docbook_xml_dtd_412
, glib
, gusb
, dbus
, polkit
, nss
, pam
, systemd
, gxfp5130-libfprint
, python3
,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fprintd-gxfp";
  version = "1.94.4";
  outputs = [ "out" "devdoc" ];

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "libfprint";
    repo = "fprintd";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-B2g2d29jSER30OUqCkdk3+Hv5T3DA4SUKoyiqHb8FeU=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    perl
    gettext
    gtk-doc
    python3
    libxslt
    dbus
    docbook-xsl-nons
    docbook_xml_dtd_412
  ];

  buildInputs = [
    glib
    polkit
    nss
    pam
    systemd
    gxfp5130-libfprint
  ];

  nativeCheckInputs = with python3.pkgs; [
    gobject-introspection
    python-dbusmock
    dbus-python
    pygobject3
    pycairo
    pypamtest
    gusb
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
    "-Dpam_modules_dir=${placeholder "out"}/lib/security"
    "-Dsysconfdir=${placeholder "out"}/etc"
    "-Ddbus_service_dir=${placeholder "out"}/share/dbus-1/system-services"
    "-Dsystemd_system_unit_dir=${placeholder "out"}/lib/systemd/system"
  ];

  PKG_CONFIG_DBUS_1_INTERFACES_DIR = "${placeholder "out"}/share/dbus-1/interfaces";
  PKG_CONFIG_POLKIT_GOBJECT_1_POLICYDIR = "${placeholder "out"}/share/polkit-1/actions";
  PKG_CONFIG_DBUS_1_DATADIR = "${placeholder "out"}/share";

  LIBRARY_PATH = lib.makeLibraryPath [ python3.pkgs.pypamtest ];

  mesonCheckFlags = [
    "--no-suite"
    "fprintd:TestPamFprintd"
  ];

  patches = [
    ./skip-test-test_removal_during_enroll.patch
    ./chicago-study-persistence.patch
  ];

  postPatch = ''
    patchShebangs \
      po/check-translations.sh \
      tests/unittest_inspector.py

  '';

  postInstall = ''
    substituteInPlace $out/lib/systemd/system/fprintd.service \
      --replace-fail "DeviceAllow=/dev/cros_fp rw" \
                     $'DeviceAllow=/dev/cros_fp rw\nDeviceAllow=/dev/gxfp rw'
  '';

  meta = {
    homepage = "https://fprint.freedesktop.org/";
    description = "D-Bus daemon that offers libfprint functionality over the D-Bus interprocess communication bus";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
})
