{ pkgs, ... }:
{
  sane.programs.dialect = {
    packageUnwrapped = pkgs.dialect.overrideAttrs (upstream: {
      # TODO: send upstream
      # TODO: figure out how to get audio working
      # TODO: move to runtimeDependencies?
      buildInputs = upstream.buildInputs ++ [
        pkgs.glib-networking  # for TLS
      ];
    });

    buildCost = 1;

    sandbox.wrapperType = "inplace";  # share/search_providers/ calls back into the binary, weird wrap semantics
    sandbox.whitelistWayland = true;
    sandbox.net = "clearnet";
    # gsettingsPersist = [ "app/drey/Dialect" ];
  };
}
