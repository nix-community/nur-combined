{
  lib,
  stdenv,
  fetchurl,
  meson,
  pkg-config,
  ninja,
  wayland-scanner,
  libffi,
  expat,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wayland";
  version = "1.23.1";

  src = fetchurl {
    url =
      with finalAttrs;
      "https://gitlab.freedesktop.org/wayland/wayland/-/releases/${version}/downloads/${pname}-${version}.tar.xz";
    hash = "sha256-hk+yqDmeLQ7DnVbp2bdTwJN3W+rcYCLOgfRBkpqB5e0=";
  };

  patches = [
    ./0001-Add-conn_id-to-wl_connection.patch
    ./0002-Pass-connection-into-wl_closure_print.patch
    ./0003-Show-conn_id-in-wl_closure_print.patch
    ./0004-Lock-stderr-while-printing-to-it.patch
  ];

  separateDebugInfo = false;
  dontStrip = true;
  mesonBuildType = "debug";

  mesonFlags = [
    (lib.mesonBool "documentation" false)
    (lib.mesonBool "tests" false)
    (lib.mesonBool "dtd_validation" false)
  ];

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs =
    [
      meson
      pkg-config
      ninja
    ];

  buildInputs =
    [
      libffi
      expat
    ];

  meta = with lib; {
    description = "Core Wayland window system code and protocol";
    homepage = "https://wayland.freedesktop.org/";
    license = licenses.mit; # Expat version
    platforms = platforms.unix;
    maintainers = with maintainers; [ wineee ];
  };
})

