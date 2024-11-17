{ pkgs, ... }:
{
  sane.programs.strings = {
    # binutils-unwrapped is like 80 MiB, just for this one binary;
    # dynamic linking means copying the binary doesn't reduce the closure much at all compared to just symlinking it.
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.binutils-unwrapped "strings";

    sandbox.wrapperType = "inplace";  # trivial package; cheaper to wrap in place
    sandbox.autodetectCliPaths = "existing";
  };
}
