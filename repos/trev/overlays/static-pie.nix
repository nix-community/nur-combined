{ }:
# Makes gcc link static executables as static PIE for ASLR, like
# https://github.com/NixOS/nixpkgs/pull/515233. Remove once that lands.
final: prev:
let
  inherit (prev) lib;
  target = final.stdenv.targetPlatform;

  # platforms with position independent code even without shared libraries.
  # mingw and cygwin gcc ignore -static-pie, so static links would become dynamic
  canReloc =
    target.isAndroid
    || target.isGnu
    || target.isMusl
    || target.isDarwin
    || target.isSunOS
    || target.isOpenBSD
    || target.isFreeBSD
    || target.isNetBSD;

  # nixpkgs already does it
  upstream = lib.functionArgs prev.gcc.cc.override ? enableDefaultStaticPie;
in
{
  gcc =
    if target.isStatic && canReloc && !upstream then
      prev.gcc.override {
        cc = (prev.gcc.cc.override { enableDefaultPie = true; }).overrideAttrs (old: {
          configureFlags = old.configureFlags ++ [
            # static -> static-pie, skipped if -r or -shared or -no-pie are set
            "--with-specs=%{!r:%{!shared:%{!no-pie:%{static:%<static -static-pie}}}}"
          ];
        });
      }
    else
      prev.gcc;
}
