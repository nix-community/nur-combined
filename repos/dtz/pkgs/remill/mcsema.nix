{ fetchFromGitHub }:

{
  version = "2018-09-04";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "940ccd5357c5a6758203b70e5332b69d662412ff";
    sha256 = "1c5xif78jx0lacj960sy35k4jb79xsckry7rn1743cd4l6sj5gvp";
    name = "mcsema-source";
  };
}
