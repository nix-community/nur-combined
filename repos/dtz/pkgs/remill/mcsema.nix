{ fetchFromGitHub }:

{
  version = "2018-08-20";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "7a0e60d8571a3531581c3b7279d2f4306dcb7f76";
    sha256 = "0ixlhj3cczc9chdw0a3didhkcacpx7msivjy35xf9gx5xmljwg0k";
    name = "mcsema-source";
  };
}
