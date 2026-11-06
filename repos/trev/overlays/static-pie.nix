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

  # gcc's link spec for these linux targets has no static-pie case, so -static-pie
  # doesn't pass -Bstatic or --no-dynamic-linker and links against libc.so
  hasStaticPie = !(target.isAarch32 || target.isMips || target.isSparc || target.isM68k);

  # nixpkgs already does it
  upstream = lib.functionArgs prev.gcc.cc.override ? enableDefaultStaticPie;

  # musl's static PIE startup only applies relative relocations, but exported thread-local
  # variables get TPOFF relocations, so don't export anything (-Wl,--export-dynamic)
  noExport = lib.optionalString target.isMusl " -Wl,--no-export-dynamic";

  # static -> static-pie, skipped if -r or -shared or -no-pie are set
  specs =
    "%{!r:%{!shared:%{!no-pie:%{static:%<static -static-pie${noExport}}}}}"
    + lib.optionalString (noExport != "") " %{static-pie:${noExport}}";
in
{
  gcc =
    if target.isStatic && canReloc && hasStaticPie && !upstream then
      prev.gcc.override {
        cc = (prev.gcc.cc.override { enableDefaultPie = true; }).overrideAttrs (old: {
          configureFlags = old.configureFlags ++ [ "--with-specs=${specs}" ];
        });
      }
    else
      prev.gcc;
}
