{ fetchFromGitHub }:

{
  version = "2019-02-15";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "d03ec7032280d50b61f817f3aceeb17790ea74e7";
    sha256 = "032mgdqfh4pzfx8qsls8phzxlifcdgwgjh3c1c9kj6nc0wybpm33";
    name = "mcsema-source";
  };
}
