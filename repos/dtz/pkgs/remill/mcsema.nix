{ fetchFromGitHub }:

{
  version = "2018-10-19";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "900caf70986cc3a46adce020512eeced3fbbe531";
    sha256 = "1wdabnn271wa7mx989dzp8jqm3wcqancml44x5iw3y9wrfs77194";
    name = "mcsema-source";
  };
}
