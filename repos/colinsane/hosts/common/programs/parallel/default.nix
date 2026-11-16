{ pkgs, ... }:
{
  sane.programs.parallel = {
    # or, the "full" version (perl deps; doesn't cross-compile)
    # packageUnwrapped = pkgs.parallel-full.override {
    #   # avoid annoying preamble on each invocation
    #   willCite = true;
    # }
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.parallel "parallel";
    sandbox.enable = false; # it runs whatever command you provide in argv
  };
}
