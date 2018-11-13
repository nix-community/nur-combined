{ fetchFromGitHub }:

{
  version = "2018-11-08";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "f68b000893c32d6ac6c61a0dd280a3562c4d8a2d";
    sha256 = "1s3pj4d0w4n304dczj4qxa7fcmdffdsl2ma4ppbjr77kwjm6qaak";
    name = "mcsema-source";
  };
}
