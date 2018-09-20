{ fetchFromGitHub }:
{
  src = fetchFromGitHub {
    owner = "seahorn";
    repo = "sea-dsa";
    rev = "360978068497162a2c14176d5566ebe82c391906";
    sha256 = "1rxivp0pqmhwfhnhmyc5a4jf217fvpmfmgxz2kxs42i4z2w1qq6l";
  };
  version = "2017-06-27";
}

