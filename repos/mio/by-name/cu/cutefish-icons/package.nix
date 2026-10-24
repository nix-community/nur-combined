{
  callPackage,
  stdenvNoCC,
  gtk3,
  lib,
}:

(callPackage ../cutefish/mk.nix { stdenv = stdenvNoCC; }) {
  pname = "cutefish-icons";
  withPkgConfig = false;
  withGettext = false;

  extraNativeBuildInputs = [ gtk3 ];

  # The Colloid-based theme ships a handful of symlinks whose targets are not
  # in the tree. Drop them so the package can be installed.
  preFixup = ''
    find "$out" -xtype l -delete
  '';

  meta = {
    description = "Icon theme for the Cutefish desktop, based on Colloid";
    license = lib.licenses.gpl3Plus;
  };
}
