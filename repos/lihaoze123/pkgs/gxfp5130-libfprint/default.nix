{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, meson
, python3
, ninja
, cmake
, gusb
, pixman
, glib
, gobject-introspection
, cairo
, libgudev
, udevCheckHook
, gtk-doc
, docbook-xsl-nons
, docbook_xml_dtd_43
, openssl
, mbedtls
, opencv4
, doctest
, nss
,
}:
let pin = lib.importJSON ../gxfp5130-libfprint/source.json;
in
stdenv.mkDerivation {
  pname = "libfprint-gxfp";
  version = "unstable";
  outputs = [ "out" "devdoc" ];

  src = fetchFromGitHub { inherit (pin) owner repo rev hash; };
  sourceRoot = "source/libfprint";

  postPatch = ''
    patchShebangs \
      tests/unittest_inspector.py \
      tests/virtual-image.py \
      tests/umockdev-test.py \
      tests/test-generated-hwdb.sh
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    cmake
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    gobject-introspection
    udevCheckHook
  ];

  buildInputs = [
    gusb
    pixman
    glib
    cairo
    libgudev
    openssl
    mbedtls
    opencv4
    doctest
    nss
  ];

  mesonFlags = [
    "-Dudev_rules_dir=${placeholder "out"}/lib/udev/rules.d"
    "-Ddrivers=gxfp"
    "-Dudev_hwdb_dir=${placeholder "out"}/lib/udev/hwdb.d"
  ];

  postInstall = ''
    install -Dm644 ../libfprint/sigfm/sigfm.hpp "$out/include/libfprint-2/sigfm/sigfm.hpp"
  '';

  nativeInstallCheckInputs = [
    (python3.withPackages (p: with p; [ pygobject3 ]))
  ];

  doCheck = false;
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    runHook postInstallCheck
  '';

  meta = {
    homepage = "https://fprint.freedesktop.org/";
    description = "Library designed to make it easy to add support for consumer fingerprint readers";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
