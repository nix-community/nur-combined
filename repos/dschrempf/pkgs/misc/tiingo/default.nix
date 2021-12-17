{ lib
, fetchFromGitHub
, python3
}:

let
  pname = "tiingo";
  version = "0.14.0";
  owner = "hydrosquall";
in
python3.pkgs.buildPythonPackage rec {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    inherit owner;
    repo = "${pname}-python";
    rev = "v${version}";
    hash = "sha256-PoRVq9ePancsZjaRIZPpseuYdKmewZwPqQ73o58BcrI=";
  };

  # src = python3.pkgs.fetchPypi {
  #   inherit pname;
  #   inherit version;
  #   hash = "sha256-zxVwbG84j1LIXUbvrg+hCSAKVx+VsMyTYQk5AsYvrAA=";
  # };

  nativeBuildInputs = with python3.pkgs; [ pytest-runner ];
  # buildInputs = [ ];
  propagatedBuildInputs = with python3.pkgs; [ requests ];

  doCheck = false;
  pythonImportsCheck = [ pname ];

  meta = with lib; {
    description = "Financial data platform";
    homepage = "https://github.com/${owner}/${pname}";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };
}
