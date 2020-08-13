{ stdenv }:

stdenv.mkDerivation rec {
  name = "mediagoblin-${version}";
  version = "1.0";
  src = fetchGit {
      url = "https://git.savannah.gnu.org/git/mediagoblin.git";
      ref = "stable";
      rev = "";
  };
  buildPhase = "echo echo Hello World > example";
  installPhase = "install -Dm755 example $out";
}

