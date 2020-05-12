{ stdenv
, fetchFromGitHub
, buildGoPackage
}:

buildGoPackage rec {
  pname = "butler";
  version = "15.17.0";
  goPackagePath = "github.com/itchio/butler";

  src = fetchFromGitHub {
    owner = "itchio";
    repo = pname;
    rev = "0833dc8a25860564c4a71625992054b40d967e83";
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

