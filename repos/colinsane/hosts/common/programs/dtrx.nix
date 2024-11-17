{ pkgs, ... }:
{
  sane.programs.dtrx = {
    packageUnwrapped = pkgs.dtrx.override {
      # `binutils` is the nix wrapper, which reads nix-related env vars
      # before passing on to e.g. `ld`.
      # dtrx probably only needs `ar` at runtime, not even `ld`.
      binutils = pkgs.binutils-unwrapped;
      # build without rpm support, since `rpm` package doesn't cross-compile.
      rpm = null;
    };
    sandbox.whitelistPwd = true;
    sandbox.autodetectCliPaths = "existing";  #< for the archive
  };
}
