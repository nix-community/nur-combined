{ stdenvNoCC, lua-amalg, fetchFromGitHub, lua5_4 ? lua5_3, lua5_3 }: stdenvNoCC.mkDerivation {
  pname = "wireplumber-scripts";
  version = "2021-10-31";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = "wireplumber-scripts";
    rev = "89c298039b685c88a6f016438b7da0883d6511d8";
    sha256 = "0ikjxxlwzx3w5v1dwjd90v76fbq4hc5m4w9v444v094n5c9k5jyi";
  };

  nativeBuildInputs = [ lua-amalg ];
  checkInputs = [ lua5_4 ];

  installFlags = [ "INSTALLDIR=${placeholder "out"}" ];
}
