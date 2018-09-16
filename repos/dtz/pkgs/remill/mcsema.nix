{ fetchFromGitHub }:

{
  version = "2018-09-15";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "38b3a78a584f782d211afcf69350180be7717832";
    sha256 = "0j5r9wnc7qjsz1lz562sfyl3b02l8w8ls9hbm0g4p0jsj6dsgflm";
    name = "mcsema-source";
  };
}
