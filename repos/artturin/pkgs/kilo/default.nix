{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "kilo";
  version = "1";

  src = fetchFromGitHub {
    owner = "antirez";
    repo = pname;
    rev = "69c3ce609d1e8df3956cba6db3d296a7cf3af3de";
    sha256 = "09a6q6976pi5dmxcn2wv2nz1ngm5pa2sghgci8f24h619ilz6czb";
  };


  installPhase = ''
    mkdir -p $out/bin
    cp kilo $out/bin

  '';

  meta = with lib; {
    description = "A text editor in less than 1000 LOC with syntax highlight and search.";
    license = licenses.bsd2;
    maintainers = with maintainers; [ artturin ];
    platforms = platforms.all;
  };
}
