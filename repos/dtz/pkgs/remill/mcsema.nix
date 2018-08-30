{ fetchFromGitHub }:

{
  version = "2018-08-29";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "4143a74905cd18804c32f9ec133a22f6a2a9d862";
    sha256 = "167hspby873pl8bwzsqzcidbxyp9d89kbpqmhsmkwx04bddwhxb6";
    name = "mcsema-source";
  };
}
