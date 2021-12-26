{ lib
, fetchFromGitHub
, python3
}:

let
  pname = "ccxt";
  version = "1.65.17";
  owner = pname;
in
python3.pkgs.buildPythonPackage rec {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    inherit owner;
    repo = pname;
    rev = "${version}";
    hash = "sha256-uXLdzAGPwJFrOlZSPUFlhgXG+qM1ZMWntv6lXD6ntRs=";
  };

  prePatch = "cd python";

  # src = python3.pkgs.fetchPypi {
  #   inherit pname;
  #   inherit version;
  #   hash = "sha256-/HKZ+tCJLHnsssSSUlfdY3jo1OHCcZ27+wMB+0fYlNo=";
  # };

  nativeBuildInputs = with python3.pkgs; [ aiodns aiohttp certifi cryptography requests yarl ];
  # buildInputs = [ ];
  # propagatedBuildInputs = [ ];

  doCheck = false;
  pythonImportsCheck = [ pname ];

  meta = with lib; {
    description = "Cryptocurrency exchange trading library";
    homepage = "https://github.com/${owner}/${pname}";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };
}
