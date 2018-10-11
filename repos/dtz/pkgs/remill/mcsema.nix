{ fetchFromGitHub }:

{
  version = "2018-10-10";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "39a10d007c030e1a00f2a997c8b2aa001863f414";
    sha256 = "01dnkhjn2npdyznv1vrb8x0rr1zs5vcrh35q08sqlfrk8fqcickz";
    name = "mcsema-source";
  };
}
