{ fetchFromGitHub }:

{
  version = "2018-08-31";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "0d4ba9e1005c7756135dcb6a5ca970c04ba68bfe";
    sha256 = "1rkr3g9v6j74afm60arjjnq8rz9v8kyms81a5gm6bjsik72wnf7v";
    name = "mcsema-source";
  };
}
