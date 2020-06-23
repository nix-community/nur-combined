{ stdenv, fetchFromGitLab
, perl, automake, autoconf
}:

stdenv.mkDerivation {
  pname = "surfraw";
  version = "unstable-2020-03-09";

  src = fetchFromGitLab {
    owner = "surfraw";
    repo = "Surfraw";
    rev = "9e87d2195cf6c2c29a68ed26f0b8d1066f2d0942";
    sha256 = "1xg8d0kx2s1ydlb4h7nba9xxsqaf86b2h5dss4jhpa11pyq8j0qw";
  };

  preConfigure = "./prebuild";
  configureFlags = [ "--disable-opensearch" ];

  nativeBuildInputs = [ perl autoconf automake ];

  meta = with stdenv.lib; {
    description = "Provides a fast unix command line interface to a variety of popular WWW search engines and other artifacts of power";
    homepage = "https://gitlab.com/surfraw/Surfraw";
    platforms = platforms.linux;
    license = licenses.publicDomain;
  };
}
