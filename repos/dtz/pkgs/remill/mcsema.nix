{ fetchFromGitHub }:

{
  version = "2018-09-26";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "8eb4cbc16d6ceb8a8f11d0484fbce9ff6ee14788";
    sha256 = "04l9ra12sl1cdcrc6arl1jka7vmxd88q92f7cl0kspinijvvs959";
    name = "mcsema-source";
  };
}
