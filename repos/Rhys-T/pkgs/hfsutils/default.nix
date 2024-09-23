{ stdenv, lib, fetchurl, maintainers }:

stdenv.mkDerivation rec {
  pname = "hfsutils";
  baseversion = "3.2.6";
  version = "${baseversion}-14";

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

  postPatch = ''
    touch .stamp/*

    substituteInPlace Makefile.in \
      --replace-fail '"$(BINDEST)/."' \
                '-Dt "$(BINDEST)"' \
      --replace-fail '"$(MANDEST)' \
                '-DT "$(MANDEST)'
    
    for configure in configure */configure; do
      sed -i 's/^main()/int main()/' "$configure"
    done
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
}
