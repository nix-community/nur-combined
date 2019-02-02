{ fetchFromGitHub }:

{
  version = "2019-01-30";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "3e473f5661acdd8735356c1b7d4ce60a1a55ded2";
    sha256 = "05sw1kxwhacspnl7zjab44cn3a5q0ixv56i1dyfma4cic9saq4bq";
    name = "mcsema-source";
  };
}
