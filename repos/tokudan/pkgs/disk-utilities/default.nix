{ stdenv, fetchFromGitHub,
 } :

stdenv.mkDerivation rec {
  version = "2020-02-12";
  pname = "disk-utilities";

  src = fetchFromGitHub {
    owner = "keirf";
    repo = "Disk-Utilities";
    rev = "09eb198bd264809af91a2f562ff9c56c7f90c605";
    sha512 = "2bv2g2j8f5g08lfdsd3w3xs8yn5sn0ky3w2ay2y724j7knqkzcp79907ss1lmfipyws67gj9dsmgw5fcss1sbidl4qzbiarsjjn2lxb";
  };

  buildInputs = [  ];

  preBuildPhases = [ "setPREFIX" ];
  setPREFIX = "export PREFIX=$out";

  meta = {
    homepage = https://github.com/keirf/Disk-Utilities;
    description  = "collection of utilities for ripping, dumping, analysing, and modifying disk images";
    #license = stdenv.lib.licenses.gpl3;
    maintainers = with stdenv.lib.maintainers; [ tokudan ];
    platforms = stdenv.lib.platforms.all;
  };
}
