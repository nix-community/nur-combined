{ lib, buildPythonPackage, fetchFromGitHub, requests }:

buildPythonPackage {
  pname = "curlify";
  version = "unstable-2019-07-19";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "ofw";
    repo = "curlify";
    rev = "b914625b12f9b05c39f305b47ebd0d1f061af24d";
    hash = "sha256-yDHmH35TtQDJB0na1V98RtBuVHX5TmKC72hzzs1DQK8=";
  };

  propagatedBuildInputs = [
    requests
  ];

  meta = with lib; {
    description = "A library to convert python requests request object to curl command";
    homepage = "https://github.com/ofw/curlify";
    licenses = licenses.mit;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}