{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "commiter";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "lmdevv";
    repo = "commiter";
    rev = "6c48577e31080317159e012910f203ea1844788a";
    sha256 = "0i48xlxk20w3bdfkdb32fj4mmh1hxfd6c9gr9d75ggpyckj85kkk";
  };

  vendorHash = null;

  meta = with lib; {
    description = "CLI tool for generating AI-powered commit messages";
    homepage = "https://github.com/lmdevv/commiter";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
  };
}
