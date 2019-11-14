{ stdenv, fetchurl, zlib, gcc, glibc, openmpi }:

stdenv.mkDerivation rec {
  version = "3.7.2";
  name = "migrate";

  src = fetchurl {
    url = "https://peterbeerli.com/migrate-html5/download_version3/migrate-${version}.src.tar.gz";
    sha256 = "0mb8b0jrjb83bp2f6if2gdwz5f0nbysc1vchn5bfa4jhxfgscr53";
  };

  buildInputs = [ zlib glibc openmpi ];
  nativeBuildInputs = [ gcc ];
  setSourceRoot = ''sourceRoot=$(echo */src)'';
  buildFlags = [ "thread" "mpis" ];
  preInstall = "mkdir -p $out/man/man1";

  meta = with stdenv.lib; {
    description = "Estimates population size, migration, population splitting parameters using genetic/genomic data";
    homepage = https://peterbeerli.com/migrate-html5/index.html;
    license = licenses.mit;
    maintainers = [ maintainers.bzizou ];
    platforms = platforms.unix;
  };
}
