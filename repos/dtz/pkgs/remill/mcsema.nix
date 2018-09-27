{ fetchFromGitHub }:

{
  version = "2018-09-27";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "f8fe0865688b78afa5a7a23759f2dec89aa8eb9d";
    sha256 = "0wxa2qj33d8mnqr14ryk75862ma3jwidnbzs0a3p2h9l0ghxrd1f";
    name = "mcsema-source";
  };
}
