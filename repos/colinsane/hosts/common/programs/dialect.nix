{ pkgs, ... }:
{
  sane.programs.dialect = {
    sandbox.method = "bwrap";

    packageUnwrapped = pkgs.dialect.overrideAttrs (upstream: {
      # TODO: send upstream
      # TODO: figure out how to get audio working
      # TODO: move to runtimeDependencies?
      buildInputs = upstream.buildInputs ++ [
        pkgs.glib-networking  # for TLS
      ];
    });

    # dialect reads settings via dconf
    fs.".config/dconf" = {};
  };
}
