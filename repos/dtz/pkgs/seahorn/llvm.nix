{ fetchFromGitHub }:
{
  src = fetchFromGitHub {
    owner = "seahorn";
    repo = "llvm-seahorn";
    rev = "39aa1875406322cca640eb68980087cd6086c52b";
    sha256 = "0v6m23nrskxvav0733lxq5z2g9l3dbzr7isa8np4vf9dm923bqmr";
  };
  version = "2017-04-04";
}
