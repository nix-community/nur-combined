{ pkgs, ... }:
{
  sane.programs.dtrx = {
    packageUnwrapped = (pkgs.dtrx.override {
      # `binutils` is the nix wrapper, which reads nix-related env vars
      # before passing on to e.g. `ld`.
      # dtrx probably only needs `ar` at runtime, not even `ld`.
      # this is a "correctness" (and closure) fix, not a build or even runtime fix (probably)
      binutils = pkgs.binutils-unwrapped;
      # build without rpm support, since `rpm` package doesn't cross-compile.
      # rpm = null;
    }).overrideAttrs (upstream: {
      # patches = (upstream.patches or []) ++ [
      #   (pkgs.fetchpatch2 {
      #     # https://github.com/dtrx-py/dtrx/pull/62
      #     # this is needed for as long as i'm interacting with .tar.lz archives which are actually LZMA and not lzip.
      #     name = "fix .tar.lz mapping";
      #     url = "https://github.com/dtrx-py/dtrx/commit/ff379f1444b142bb461f26780e32f82e60856be2.patch";
      #     hash = "sha256-WNz5i/iJqyxmZh/1mw6M8hWeiQdRvyhCta7gN/va6lQ=";
      #   })
      # ];
    });
    sandbox.whitelistPwd = true;
    sandbox.autodetectCliPaths = "existing";  #< for the archive
  };
}
