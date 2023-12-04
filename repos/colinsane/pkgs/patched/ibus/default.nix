{ ibus
, buildPackages
, fetchFromGitHub
, gobject-introspection
, lib
, libdbusmenu-gtk3
, pkg-config
, pkgs
, stdenv
, ...
}@attrs:
let
  isCross = !(stdenv.buildPlatform.canExecute stdenv.hostPlatform);
in
(ibus.override
  (removeAttrs attrs [ "ibus" "libdbusmenu-gtk3" "pkgs" ] )
).overrideAttrs (upstream: rec {
  # compared to 1.5.28, this version supports better cross compilation
  version = "1.5.29";
  src = fetchFromGitHub {
    owner = "ibus";
    repo = "ibus";
    rev = version;
    hash = "sha256-d4EUIg0v8rfHdvzG5USc6GLY6QHtQpIJp1PrPaaBxxE=";
  };
  patches = [(builtins.head upstream.patches)] ++ [
    # this patch is in nixpkgs 1.5.28, but doesn't cleanly apply to this current version
    ./build-without-dbus-launch.patch
    # AC_CHECK_FILE has an explicit guard against cross compiling, which is silly if you think about it for more than a second.
    ./configure-no-ac-check-file.patch
  ];

  # vapigen (vala) is nativeBuildInputs, so fix the PKG_CONFIG ibus uses to find it.
  # ibus does an extra sanity check with `PKG_CHECK_EXISTS`, but that doesn't support
  # PKG_CONFIG_FOR_BUILD, so turn its error into just a warning.
  postPatch = (upstream.postPatch or "") + lib.optionalString isCross ''
    substituteInPlace m4/vapigen.m4 \
      --replace PKG_PROG_PKG_CONFIG PKG_PROG_PKG_CONFIG_FOR_BUILD \
      --replace 'PKG_CONFIG ' 'PKG_CONFIG_FOR_BUILD ' \
      --replace 'AC_MSG_ERROR([$vapigen_pkg not found])' 'AC_MSG_WARN([$vapigen_pkg not found])'
  '';

  configureFlags = upstream.configureFlags ++ [
    "--enable-vala"
    # fix "python version is too old"
    "--with-python=${buildPackages.python3.interpreter}"
  ];
  env.GLIB_COMPILE_RESOURCES="${lib.getDev buildPackages.glib}/bin/glib-compile-resources";

  # to debug:
  # makeFlags = upstream.makeFlags ++ [ "V=1" ];

  depsBuildBuild = (upstream.depsBuildBuild or []) ++ [
    buildPackages.stdenv.cc
    pkg-config
  ];

  buildInputs = upstream.buildInputs ++ [
    libdbusmenu-gtk3
  ];
})
