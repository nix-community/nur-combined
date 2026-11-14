# Retained from nixpkgs for Baidu Netdisk's GTKmm 2.4 ABI dependency.
{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  gtk2,
  glibmm_2_4,
  cairomm_1_0,
  pangomm_1_4,
  atkmm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtkmm";
  version = "2.24.5";

  src = fetchurl {
    url = "mirror://gnome/sources/gtkmm/${lib.versions.majorMinor finalAttrs.version}/gtkmm-${finalAttrs.version}.tar.xz";
    sha256 = "0680a53b7bf90b4e4bf444d1d89e6df41c777e0bacc96e9c09fc4dd2f5fe6b72";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = [
    glibmm_2_4
    gtk2
    atkmm
    cairomm_1_0
    pangomm_1_4
  ];

  doCheck = true;
  enableParallelBuilding = true;

  meta = {
    description = "C++ interface to GTK 2";
    homepage = "https://gtkmm.gnome.org/";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.linux;
  };
})
