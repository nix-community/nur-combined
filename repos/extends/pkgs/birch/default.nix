{ stdenv, fetchFromGitHub, bash, coreutils, makeWrapper }:
let
  binPath = [ 
    coreutils
    bash
  ];
in stdenv.mkDerivation rec {
  name = "birch";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "dylanaraps";
    repo = "birch";
    rev = "27691aa4fb2746f73c373e6653c1fb17795729f9";
    sha256 = "8TBsrRmpMl0z9e2gbPpj0ZR0zt1Kn+A4xRAq89Ww4og=";
  };

  phases = [ "installPhase" "postFixup" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/birch $out/bin
  '';

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/${name} --prefix PATH : ${stdenv.lib.makeBinPath binPath}
  '';

  meta = with stdenv.lib; {
    description = "IRC Client.";
    homepage = "https://github.com/dylanaraps/birch";
    maintainers = with maintainers; [ extends ];
    license = licenses.mit;
    platform = platforms.all;
  };
}
