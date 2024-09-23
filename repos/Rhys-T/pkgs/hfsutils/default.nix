{ stdenv, lib, writeShellScript, fetchurl, fetchpatch, enableTclTk ? false, tcl, tk, maintainers }:

stdenv.mkDerivation rec {
  pname = "hfsutils";
  baseversion = "3.2.6";
  version = "${baseversion}-14";
  
  buildInputs = lib.optionals enableTclTk [tcl tk];
  configureFlags = [(lib.withFeatureAs enableTclTk "tcl" "${tcl}") (lib.withFeatureAs enableTclTk "tk" "${tk}")];
  env.NIX_CFLAGS_COMPILE = lib.optionalString (stdenv.cc.isClang && enableTclTk) "-Wno-error=incompatible-function-pointer-types";

  srcs = [
    # Actual source
    (fetchurl {
      name = "${pname}-${baseversion}.tar.gz";
      urls = [
        "ftp://ftp.mars.org/pub/hfs/${pname}-${baseversion}.tar.gz"
        "http://deb.debian.org/debian/pool/main/h/${pname}/${pname}_${baseversion}.orig.tar.gz"
      ];
      sha256 = "0h4q51bjj5dvsmc2xx1l7ydii9jmfq5y066zkkn21fajsbb257dw";
    })

    # Debian packaging files, for the patches
    (fetchurl {
      name = "patches-${baseversion}.tar.xz";
      url = "http://deb.debian.org/debian/pool/main/h/${pname}/${pname}_${version}.debian.tar.xz";
      sha256 = "1b67vfcf679yk8yp1msyzsjfswpqh8mllkcrgbiy7l7a9ynvsp45";
    })
  ];

  sourceRoot = "${pname}-${baseversion}";

  # Apply patches from debian
  prePatch = ''
    for p in $(cat ../debian/patches/series); do
      patches+=" ../debian/patches/$p"
    done
  '';

  patches = [
    ./0001-Don-t-set-ug-id-unless-it-s-actually-different.patch
  ] ++ lib.optionals enableTclTk [
    ./0002-Rename-bitmaps-to-avoid-conflict-with-Mac-builtins.patch
    (fetchpatch {
      name = "0003-xhfs-Use-Tcl_Alloc-Tcl_Free-as-required-when-interac.patch";
      url = https://github.com/JotaRandom/hfsutils/commit/e62ea3c5ac49ca894db853d966f1cd2cb808f35c.patch;
      hash = "sha256-gEvzZAHb3cfGY8/gQI9woK48a+cn+wiXhhslHgg/osI=";
    })
  ];

  postPatch = ''
    touch .stamp/*

    for configure in configure */configure; do
      sed -i 's/^main()/int main()/' "$configure"
    done
    substituteInPlace Makefile.in \
      --replace-fail '"$(BINDEST)/."' \
                '-Dt "$(BINDEST)"' \
      --replace-fail '"$(MANDEST)' \
                '-DT "$(MANDEST)'
    
    sed -i '1i\
    #include <string.h>
    ' hpwd.c
  '';

  meta = {
    description = "HFS utilities";
    # maintainers = with maintainers; [ dtzWill ];
    maintainers = [maintainers.Rhys-T];
    license = lib.licenses.gpl2Plus;
    homepage = "https://www.mars.org/home/rob/proj/hfs";
  };
  
  passthru._Rhys-T.flakeApps = name: hfsutils: lib.optionalAttrs enableTclTk {
    xhfs = {
      type = "app";
      program = lib.getExe' hfsutils "xhfs";
    };
  };
}
