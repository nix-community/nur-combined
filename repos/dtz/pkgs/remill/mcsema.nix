{ fetchFromGitHub }:

{
  version = "2018-09-07";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "6187d254b0c182b70b12e5d09b53f814852e7a44";
    sha256 = "1dkaankylfc5sm3zphc6c0niw3f5dfkkybqvhf6nqi0cmvxsvf8y";
    name = "mcsema-source";
  };
}
