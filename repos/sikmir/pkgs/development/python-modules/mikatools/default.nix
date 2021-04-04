{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "mikatools";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "mikahama";
    repo = pname;
    rev = version;
    sha256 = "1sj39slscbk8zqxs15bc31r0vn3wr6sq7zk18gw8plfk6ccs9yq9";
  };

  propagatedBuildInputs = with python3Packages; [ requests clint cryptography ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Mikatools provides fast and easy methods for common Python coding tasks";
    homepage = "https://github.com/mikahama/mikatools";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
