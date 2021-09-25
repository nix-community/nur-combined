{ stdenvNoCC, lua-amalg, fetchFromGitHub, lua5_4 ? lua5_3, lua5_3 }: stdenvNoCC.mkDerivation {
  pname = "wireplumber-scripts";
  version = "2021-09-24";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = "wireplumber-scripts";
    rev = "c950537ff8c373113edd333a7628ef3d96e39a9c";
    sha256 = "1gnfdq74i7bb1yir00qrllcc8443ymdps7gj41hvq31a6nb9i1fj";
  };

  nativeBuildInputs = [ lua-amalg ];
  checkInputs = [ lua5_4 ];

  installFlags = [ "INSTALLDIR=${placeholder "out"}" ];
}
