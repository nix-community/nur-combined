{ pkgs, ... }:
{
  sane.programs.dialect = {
    sandbox.method = "bwrap";
    sandbox.extraHomePaths = [
      ".config/dconf"  # to persist settings
    ];

    packageUnwrapped = pkgs.dialect.overrideAttrs (upstream: {
      # TODO: send upstream
      # TODO: figure out how to get audio working
      # TODO: move to runtimeDependencies?
      buildInputs = upstream.buildInputs ++ [
        pkgs.glib-networking  # for TLS
      ];
    });
  };
}
