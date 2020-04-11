{ stdenv
, targetPackages
, crossStageStatic, libcCross
, version
, gmp, mpfr, libmpc, libelf, isl
, enableLTO
, enableMultilib
, enablePlugin
, enableShared
, langC
, langCC
, langJit
}:

let
  inherit (stdenv) buildPlatform hostPlatform targetPlatform lib;
  crossMingw = false;
  crossDarwin = false;
  configureFlags =
    # Basic dependencies
    [
      "--with-gmp-include=${gmp.dev}/include"
      "--with-gmp-lib=${gmp.out}/lib"
      "--with-mpfr-include=${mpfr.dev}/include"
      "--with-mpfr-lib=${mpfr.out}/lib"
      "--with-mpc=${libmpc}"
    ]
    ++ lib.optional (libelf != null) "--with-libelf=${libelf}"
    ++ lib.optional (!(crossMingw && crossStageStatic))
      "--with-native-system-header-dir=${lib.getDev stdenv.cc.libc}/include"

    # Basic configuration
    ++ [
      (lib.enableFeature enableLTO "lto")
      "--disable-libstdcxx-pch"
      "--without-included-gettext"
      "--with-system-zlib"
      "--enable-static"
      "--enable-languages=${
        lib.concatStrings (lib.intersperse ","
          (  lib.optional langC        "c"
          ++ lib.optional langCC       "c++"
          ++ lib.optional langJit      "jit"
          )
        )
      }"
    ]

    ++ lib.optional langJit "--enable-host-shared"
    ++ (if (enableMultilib || targetPlatform.isAvr)
      then ["--enable-multilib" "--disable-libquadmath"]
      else ["--disable-multilib"])
    ++ lib.optional (!enableShared) "--disable-shared"
    ++ [
      (lib.enableFeature enablePlugin "plugin")
    ]

    # Optional features
    ++ lib.optional (isl != null) "--with-isl=${isl}"

    ++ (import ../common/platform-flags.nix { inherit (stdenv) lib targetPlatform; })
  ;

in configureFlags
