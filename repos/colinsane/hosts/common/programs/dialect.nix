{ pkgs, ... }:
{
  sane.programs.dialect = {
    package = pkgs.dialect.overrideAttrs (upstream: {
      # TODO: send upstream
      # TODO: figure out how to get audio working
      # TODO: move to runtimeDependencies?
      buildInputs = upstream.buildInputs ++ [
        pkgs.glib-networking  # for TLS
      ];
    });
  };
}
