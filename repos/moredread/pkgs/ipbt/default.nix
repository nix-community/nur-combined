{ stdenv, lib, fetchurl, ncurses, perl }:

stdenv.mkDerivation rec {
  name = "ipbt-${version}";
  version = "20190601";

  src = fetchurl rec {
    url = "https://www.chiark.greenend.org.uk/~sgtatham/ipbt/ipbt-20190601.d1519e0.tar.gz";
    sha256 = "1aj8pajdd81vq2qw6vzfm27i0aj8vfz9m7k3sda30pnsrizm06d5";
  };

  buildInputs = [ ncurses perl ];

  meta = {
    homepage = https://www.chiark.greenend.org.uk/~sgtatham/ipbt;
    description = "WIP: ttyrec player";
    #license = lib.licenses.gpl3;
  };
}
