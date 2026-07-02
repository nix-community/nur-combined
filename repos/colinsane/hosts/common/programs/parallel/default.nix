{ pkgs, ... }:
{
  sane.programs.parallel = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage (
      pkgs.parallel-full.override {
        # avoid annoying preamble on each invocation
        willCite = true;
      }
    ) "parallel";
    sandbox.enable = false;  # it runs whatever command you provide in argv
  };
}
