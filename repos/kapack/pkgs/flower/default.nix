{ lib, pkgs, fetchFromGitHub, python3Packages, iterators }:

python3Packages.buildPythonPackage rec {
  pname = "flower";
  version = "1.4.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "adap";
    repo = "flower";
    rev = "v${version}";
    sha256 = "sha256-dfe41CtUcsxZEvs3tRUfPCO0rEgM7zGGsyWwzTIuTcg=";
  };
  patches = [
    ./0001-loosen-protobuf-version-requirement.patch
  ];

  nativeBuildInputs = [ python3Packages.poetry ];
  propagatedBuildInputs = with python3Packages; [
    numpy
    protobuf
    grpcio
    iterators
  ];

  meta = with lib; {
    longDescription = ''
      A unified approach to federated learning, analytics, and evaluation.
      Federate any workload, any ML framework, and any programming language.'';
    description = ''A Friendly Federated Learning Framework.'';
    homepage = "https://flower.dev/";
    platforms = platforms.all;
    license = licenses.asl20;
    broken = false;
  };
}
