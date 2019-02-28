{ fetchFromGitHub }:

{
  version = "2019-02-26";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "5984250bc66d39925a0664a7dd5fc1dbe1301ccc";
    sha256 = "01vqyy5vc1w2y22l0jklhvpxwz2ffkfbajij7nq409naxfh70nyp";
    name = "mcsema-source";
  };
}
