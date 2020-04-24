{ stdenv, file, fetchurl, fetchpatch, libnsl }:

stdenv.mkDerivation rec {
  name = "libspf2-${version}";
  version = "1.2.10";

  patches = [
    (fetchpatch {
      name = "fix-variadic-macros.patch";
      url = "https://git.archlinux.org/svntogit/community.git/plain/trunk/fix-variadic-macros.patch?h=packages/libspf2";
      sha256 = "00dqpcgjr9jy2qprgqv2qiyvq8y3wlz4yns9xzabf2064jzqh2ic";
    })
  ];
  preConfigure = ''
    sed -i -e "s@/usr/bin/file@${file}/bin/file@" ./configure
    '';
  configureFlags = [
    "--enable-static"
  ];
  postInstall = ''
    rm $out/bin/*_static
    '';
  src = fetchurl {
    url = "https://www.libspf2.org/spf/${name}.tar.gz";
    sha256 = "1j91p0qiipzf89qxq4m1wqhdf01hpn1h5xj4djbs51z23bl3s7nr";
  };

  buildInputs = [ libnsl ];

  meta = with stdenv.lib; {
    description = "Sender Policy Framework record checking library";
    homepage = https://www.libspf2.org/;
    platforms = platforms.unix;
  };
}
