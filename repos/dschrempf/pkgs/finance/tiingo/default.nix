{
  lib,
  fetchFromGitHub,
  python3,
}:

let
  pname = "tiingo";
  version = "0.15.6";
  owner = "hydrosquall";
in
python3.pkgs.buildPythonPackage rec {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    inherit owner;
    repo = "${pname}-python";
    rev = "v${version}";
    hash = "sha256-EVWhOjacFp6sAv0RTEXi6q5GM8R+35SSNUrbYFtultE=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    requests
    websocket_client
  ];

  doCheck = false;
  pythonImportsCheck = [ pname ];

  meta = with lib; {
    description = "Financial data platform";
    homepage = "https://github.com/${owner}/${pname}-python";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };
}
