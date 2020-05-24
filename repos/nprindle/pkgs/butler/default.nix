{ stdenv
, fetchFromGitHub
, buildGoPackage
}:

buildGoPackage rec {
  pname = "butler";
  version = "15.17.0";
  goPackagePath = "github.com/itchio/butler";

  src = fetchFromGitHub rec {
    owner = "itchio";
    repo = pname;
    rev = version;
    sha256 = "06iylqh9y5flsjij641xci7avrscvbhzvmgw1q7jnh4idzxm22hk";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "Command-line itch.io helper";
    homepage = "https://github.com/itchio/butler";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}

