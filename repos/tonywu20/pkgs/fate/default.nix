{ stdenv, fetchgit, boost, gdal }:

stdenv.mkDerivation rec {
  name = "fate";
  version = "6.2-0";

  src = fetchgit {
    url = "https://gricad-gitlab.univ-grenoble-alpes.fr/biomove/fate";
    #rev = "refs/tags/6.2-0-svn-import";
    rev = "5ef38619387da9d47a5725e378c2de0b9ee5cede";
    sha256 = "0vz87wzpklqwi7xbw4vav7hrrd1qkydbrmjfj3vnn2bpd86bgs0b";
  };

  nativeBuildInputs = [ boost gdal ];

  preConfigure = ''
    sed -i "s|PREFIX.*=.*|PREFIX = $out|" Makefile
  '';

}
