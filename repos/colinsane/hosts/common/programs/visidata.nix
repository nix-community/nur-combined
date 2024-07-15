{ pkgs, ... }:
{
  sane.programs.visidata = {
    packageUnwrapped = pkgs.visidata.overridePythonAttrs (upstream: {
      # XXX(2024/07/07): tests fail due to python 3.12 string formatting differences (inconsequential)
      doCheck = false;
    });

    sandbox.method = "bwrap";  # TODO:sandbox: untested
    sandbox.autodetectCliPaths = true;
  };
}
