{ pkgs, ... }:
{
  sane.programs.dtrx = {
    packageUnwrapped = (pkgs.dtrx.override {
      # `binutils` is the nix wrapper, which reads nix-related env vars
      # before passing on to e.g. `ld`.
      # dtrx probably only needs `ar` at runtime, not even `ld`.
      # this is a "correctness" (and closure) fix, not a build or even runtime fix (probably)
      # binutils = pkgs.binutils-unwrapped;
      # build without rpm support, since `rpm` package doesn't cross-compile.
      # rpm = null;
      # arjSupport = true;
      # unrarSupport = true;
      # unzipSupport = true;
    }).overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        (pkgs.fetchpatch {
          # out for PR: <https://github.com/dtrx-py/dtrx/pull/73>
          name = "support .a archive format";
          url = "https://github.com/uninsane/dtrx/commit/9210f853d96b3b0d2a800e3c3e14bb3399b2475b.patch?full_index=1";
          hash = "sha256-yEycG6zVUt3SLbFO9jKDbNw8GvfcQ0S3MLYn9baEQDY=";
        })
      ];
    });
    sandbox.whitelistPwd = true;
    sandbox.autodetectCliPaths = "existing";  #< for the archive
  };
}
