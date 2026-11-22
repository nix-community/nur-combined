{
  sable-next,
  rustPlatform,
  aws-lc,
  gdk-pixbuf,
  glib,
  gtk3,
  pango,
  pkg-config,
  sqlite,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sable-next-server";
  inherit (sable-next.unwrapped)
    version
    src
    patches
    cargoDeps
    ;

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    aws-lc
    # Ridiculous that the server has to depend on desktop stuff, but because of Sable's dependency
    # graph this currently cannot be solved
    gdk-pixbuf
    glib
    gtk3
    pango
    sqlite
    zstd
  ];

  cargoBuildFlags = [
    "-p"
    "sable-server"
  ];

  doCheck = false; # TODO: very broken

  env = {
    LIBSQLITE3_SYS_USE_PKG_CONFIG = true;
    SABLE_BUILD_FLAVOR = "stable";
    VERSION = finalAttrs.version;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  meta = {
    inherit (sable-next.meta)
      description
      homepage
      changelog
      license
      maintainers
      ;

    mainProgram = "sable-server";
  };
})
