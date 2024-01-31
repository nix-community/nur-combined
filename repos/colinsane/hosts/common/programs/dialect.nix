{ pkgs, ... }:
{
  sane.programs.dialect = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";  # share/search_providers/ calls back into the binary, weird wrap semantics
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
