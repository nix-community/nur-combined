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
    rev = "2b5a65d4934e40d289c1156b9b7e7288d2501140";
    sha256 = "1c3j9s366b766pbzglp02r05axfd086d2vn7jra28kzjmfd5aygg";
  };

  vendorHash = null;

  meta = with lib; {
    description = "CLI tool for generating AI-powered commit messages";
    homepage = "https://github.com/lmdevv/commiter";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
  };
}
