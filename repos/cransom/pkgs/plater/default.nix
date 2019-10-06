{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "plater-${version}";
  version = "8c690c7";
  src = fetchFromGitHub {
    owner = "Rhoban";
    repo = "plater";
    rev = "8c690c7c71a9a6ab5b964380d0027ac1a7e12281";
    sha256 = "sha256:005gv5dw6gdb04ns23vqhyh9vk82czxcdmca9wcmwvdy8n82gkkk";

  };
  buildInputs = [ cmake ];
  preConfigure = ''
    cd plater
  '';
}
