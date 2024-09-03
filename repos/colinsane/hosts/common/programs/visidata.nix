{ pkgs, ... }:
{
  sane.programs.visidata = {
    packageUnwrapped = (pkgs.visidata.override {
      zulip = null;  #< XXX(2024-08-17): security vulnerability, but completely useless anyway so disable. see: <https://github.com/NixOS/nixpkgs/pull/334638>
    }).overridePythonAttrs (upstream: {
      # XXX(2024/07/07): tests fail due to python 3.12 string formatting differences (inconsequential)
      doCheck = false;
    });

    sandbox.method = "bunpen";
    sandbox.autodetectCliPaths = true;
  };
}
