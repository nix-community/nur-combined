{ fetchFromGitHub }:

{
  version = "2019-03-23";
  src = fetchFromGitHub rec {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "59ed86dc40a61b7650860843831ed6143632f97b";
    sha256 = "176m96x866schnrjmz9q8q7jp5igdacp5xs4z5c6nn8clb3y5lkn";
    name = "mcsema-src";
  };
}
