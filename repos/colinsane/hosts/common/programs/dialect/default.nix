{ ... }:
{
  sane.programs.dialect = {
    buildCost = 1;

    sandbox.wrapperType = "inplace";  # share/search_providers/ calls back into the binary, weird wrap semantics
    sandbox.whitelistWayland = true;
    sandbox.net = "clearnet";
    # gsettingsPersist = [ "app/drey/Dialect" ];

    sandbox.mesaCacheDir = ".cache/dialect/mesa";  # TODO: is this the correct app-dir?
  };
}
