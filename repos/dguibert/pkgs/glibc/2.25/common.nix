/* Build configuration used to build glibc, Info files, and locale
   information.  */

{ stdenv, lib
, buildPackages
, fetchurl
, linuxHeaders ? null
, gd ? null, libpng ? null
, bison
}:

{ name
, withLinuxHeaders ? false
, profilingLibraries ? false
, withGd ? false
, meta
, ...
} @ args:

let
  version = "2.25";
  patchSuffix = "-49";
  sha256 = "067bd9bb3390e79aa45911537d13c3721f1d9d3769931a30c2681bfee66f23a0";
in

assert withLinuxHeaders -> linuxHeaders != null;
assert withGd -> gd != null && libpng != null;

stdenv.mkDerivation ({
  inherit version;
  linuxHeaders = if withLinuxHeaders then linuxHeaders else null;

  inherit (stdenv) is64bit;

  enableParallelBuilding = true;

  patches =
    [
      /*  No tarballs for stable upstream branch, only https://sourceware.org/git/?p=glibc.git
          $ git co release/2.25/master; git describe
          glibc-2.25-49-gbc5ace67fe
          $ git show --reverse glibc-2.25..release/2.25/master | gzip -n -9 --rsyncable - > 2.25-49.patch.gz
      */
      ./2.25-49.patch.gz

      /* Have rpcgen(1) look for cpp(1) in $PATH.  */
      ./rpcgen-path.patch

      /* Allow NixOS and Nix to handle the locale-archive. */
      ./nix-locale-archive.patch

      /* Don't use /etc/ld.so.cache, for non-NixOS systems.  */
      ./dont-use-system-ld-so-cache.patch

      /* Don't use /etc/ld.so.preload, but /etc/ld-nix.so.preload.  */
      ./dont-use-system-ld-so-preload.patch

      /* The command "getconf CS_PATH" returns the default search path
         "/bin:/usr/bin", which is inappropriate on NixOS machines. This
         patch extends the search path by "/run/current-system/sw/bin". */
      ./fix_path_attribute_in_getconf.patch
    ]
    ++ lib.optional stdenv.isx86_64 ./fix-x64-abi.patch;

  postPatch =
    ''
      # Needed for glibc to build with the gnumake 3.82
      # http://comments.gmane.org/gmane.linux.lfs.support/31227
      sed -i 's/ot \$/ot:\n\ttouch $@\n$/' manual/Makefile

      # nscd needs libgcc, and we don't want it dynamically linked
      # because we don't want it to depend on bootstrap-tools libs.
      echo "LDFLAGS-nscd += -static-libgcc" >> nscd/Makefile
    ''
    # Replace the date and time in nscd by a prefix of $out.
    # It is used as a protocol compatibility check.
    # Note: the size of the struct changes, but using only a part
    # would break hash-rewriting. When receiving stats it does check
    # that the struct sizes match and can't cause overflow or something.
    + ''
      cat ${./glibc-remove-datetime-from-nscd.patch} \
        | sed "s,@out@,$out," | patch -p1
    '';

  configureFlags =
    [ "-C"
      "--enable-add-ons"
      "--enable-obsolete-nsl"
      "--enable-obsolete-rpc"
      "--sysconfdir=/etc"
      "--enable-stackguard-randomization"
      (lib.withFeatureAs withLinuxHeaders "headers" "${linuxHeaders}/include")
      (lib.enableFeature profilingLibraries "profile")
    ] ++ lib.optionals withLinuxHeaders [
      "--enable-kernel=3.2.0" # can't get below with glibc >= 2.26
    ] ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
      (lib.flip lib.withFeature "fp"
         (stdenv.hostPlatform.platform.gcc.float or (stdenv.hostPlatform.parsed.abi.float or "hard") == "soft"))
      "--with-__thread"
    ] ++ lib.optionals (stdenv.hostPlatform == stdenv.buildPlatform && stdenv.hostPlatform.isAarch32) [
      "--host=arm-linux-gnueabi"
      "--build=arm-linux-gnueabi"

      # To avoid linking with -lgcc_s (dynamic link)
      # so the glibc does not depend on its compiler store path
      "libc_cv_as_needed=no"
    ] ++ lib.optional withGd "--with-gd";

  installFlags = [ "sysconfdir=$(out)/etc" ];

  outputs = [ "out" "bin" "dev" "static" ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ bison ];
  buildInputs = lib.optionals withGd [ gd libpng ];

  # Needed to install share/zoneinfo/zone.tab.  Set to impure /bin/sh to
  # prevent a retained dependency on the bootstrap tools in the stdenv-linux
  # bootstrap.
  BASH_SHELL = "/bin/sh";

  passthru = { inherit version; };
}

// (removeAttrs args [ "withLinuxHeaders" "withGd" ]) //

{
  name = name + "-${version}${patchSuffix}";

  src = fetchurl {
    url = "mirror://gnu/glibc/glibc-${version}.tar.xz";
    inherit sha256;
  };

  # Remove absolute paths from `configure' & co.; build out-of-tree.
  preConfigure = ''
    export PWD_P=$(type -tP pwd)
    for i in configure io/ftwtest-sh; do
        # Can't use substituteInPlace here because replace hasn't been
        # built yet in the bootstrap.
        sed -i "$i" -e "s^/bin/pwd^$PWD_P^g"
    done

    mkdir ../build
    cd ../build

    configureScript="`pwd`/../$sourceRoot/configure"

    ${lib.optionalString (stdenv.cc.libc != null)
      ''makeFlags="$makeFlags BUILD_LDFLAGS=-Wl,-rpath,${stdenv.cc.libc}/lib"''
    }


  '' + lib.optionalString (stdenv.hostPlatform != stdenv.buildPlatform) ''
    sed -i s/-lgcc_eh//g "../$sourceRoot/Makeconfig"

    cat > config.cache << "EOF"
    libc_cv_forced_unwind=yes
    libc_cv_c_cleanup=yes
    libc_cv_gnu89_inline=yes
    # Only due to a problem in gcc configure scripts:
    libc_cv_sparc64_tls=${if stdenv.hostPlatform.withTLS then "yes" else "no"}
    EOF
  '';

  preBuild = lib.optionalString withGd "unset NIX_DONT_SET_RPATH";

  meta = {
    homepage = http://www.gnu.org/software/libc/;
    description = "The GNU C Library";

    longDescription =
      '' Any Unix-like operating system needs a C library: the library which
         defines the "system calls" and other basic facilities such as
         open, malloc, printf, exit...

         The GNU C library is used as the C library in the GNU system and
         most systems with the Linux kernel.
      '';

    license = lib.licenses.lgpl2Plus;

    maintainers = [ lib.maintainers.eelco ];
    platforms = lib.platforms.linux;
  } // meta;
}

// lib.optionalAttrs (stdenv.hostPlatform != stdenv.buildPlatform) {
  preInstall = null; # clobber the native hook

  # To avoid a dependency on the build system 'bash'.
  preFixup = ''
    rm -f $bin/bin/{ldd,tzselect,catchsegv,xtrace}
  '';
})
