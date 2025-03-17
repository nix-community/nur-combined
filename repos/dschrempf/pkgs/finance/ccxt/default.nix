{
  lib,
  fetchFromGitHub,
  python3,
}:

let
  pname = "ccxt";
  version = "2.4.5";
  owner = pname;
in
python3.pkgs.buildPythonPackage rec {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    inherit owner;
    repo = pname;
    rev = "${version}";
    hash = "sha256-gB2D9OTH0fW/SqcVoRYGmCgpiqVEdrx5XNiTqJ27UTU=";
  };

  prePatch = "cd python";

  nativeBuildInputs = with python3.pkgs; [
    aiodns
    certifi
    yarl
  ];
  # buildInputs = [ ];
  propagatedBuildInputs = with python3.pkgs; [
    aiohttp
    cryptography
    requests
  ];

  doCheck = false;
  pythonImportsCheck = [ pname ];

  meta = with lib; {
    description = "Cryptocurrency exchange trading library";
    homepage = "https://github.com/${owner}/${pname}";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };
}
