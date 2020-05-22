{ stdenv, fetchFromGitHub, gnugrep }:

stdenv.mkDerivation {
  name = "git-credential-password-store";
  src = fetchFromGitHub {
    owner = "ccrusius";
    repo = "git-credential-password-store";
    rev = "225582e9a1a9bd9a63e3dfde858f4cc028b07d3e";
    sha256 = "06ly4qcy0g57jyqnl5q524pcypm85ny4pzac3ljz1dim181zlq3c";
  };
  preBuild = "ln -s GNUmakefile Makefile";
  installFlags = "PREFIX=$(out)";
  buildInputs = [ gnugrep ];
}
