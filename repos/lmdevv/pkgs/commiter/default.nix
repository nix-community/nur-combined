{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "committer";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "lmdevv";
    repo = "committer";
    rev = "e058f5a33deaab37d1d83cda25c17aec684abab4";
    sha256 = "0q2nnk0g6r5074qk5zzxhfw9j24avm01m9n5l1ryvxsg3k04m68h";
  };

  vendorHash = null;

  meta = with lib; {
    description = "CLI tool for generating AI-powered commit messages";
    homepage = "https://github.com/lmdevv/committer";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
  };
}
