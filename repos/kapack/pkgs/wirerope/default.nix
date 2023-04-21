{ python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  name = "wirerope";
  version = "0.4.5";
  src = fetchFromGitHub {
    owner = "youknowone";
    repo = name;
    rev = "81c533d6df479cae80f74b5c298c4236f98f0158";
    sha256 = "sha256-IZOu3JNNd/g19KeaeeJUXr0Ia+n5iffuZqNonfwCG8k=";
  };
  propagatedBuildInputs = with python3Packages; [
    six
  ];
  doCheck = false;
}
