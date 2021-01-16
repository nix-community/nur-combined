{ stdenv
, fetchFromGitHub
, buildGoPackage
}:

buildGoPackage rec {
  pname = "butler";
  version = "15.20.0";
  goPackagePath = "github.com/itchio/butler";

  src = fetchFromGitHub rec {
    owner = "itchio";
    repo = pname;
    rev = "v${version}";
    sha256 = "14pmbmyb4p3v4v1zy1w19da0wlayj6m8288c4mn5p0nrj8258c5i";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "Command-line itch.io helper";
    homepage = "https://github.com/itchio/butler";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}

