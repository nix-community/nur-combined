{ pkgs, ... }:
{
  sane.programs.dialect = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";  # share/search_providers/ calls back into the binary, weird wrap semantics
    sandbox.whitelistWayland = true;
    sandbox.net = "clearnet";
    sandbox.extraHomePaths = [
      ".config/dconf"  # won't start without it
    ];
    suggestedPrograms = [ "dconf" ];  #< to persist settings

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
