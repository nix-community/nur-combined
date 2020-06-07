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
    rev = "v${version}";
    sha256 = "02cp5wlsp46fifqjy8bqdvh8ad41897qhgajq4qi3jr13vlym7wy";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "Command-line itch.io helper";
    homepage = "https://github.com/itchio/butler";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}

