{ buildPythonPackage, fetchFromGitHub }:
buildPythonPackage rec {
  pname = "compdb";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Sarcasm";
    repo = "compdb";
    rev = "v${version}";
    sha256 = "0f4x0gm5n1mr87dx3gzn5da16a1qhd2y3kz22dl5xsd9pd720l4w";
  };
}
