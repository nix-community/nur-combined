{ lib
, fetchFromGitHub
, python3
}:

let
  pname = "ccxt";
  version = "1.86.7";
  owner = pname;
in
python3.pkgs.buildPythonPackage rec {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    inherit owner;
    repo = pname;
    rev = "${version}";
    hash = "sha256-UJxDK6e89TU1gzmALo2D6KZcHRfnTpuXA9GZHOFj5JU=";
  };

  prePatch = "cd python";

  nativeBuildInputs = with python3.pkgs; [ aiodns certifi yarl ];
  # buildInputs = [ ];
  propagatedBuildInputs = with python3.pkgs; [ aiohttp cryptography requests ];

  doCheck = false;
  pythonImportsCheck = [ pname ];

  meta = with lib; {
    description = "Cryptocurrency exchange trading library";
    homepage = "https://github.com/${owner}/${pname}";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };
}
