{ lib
, python3
, fetchFromGitHub
, nodejs
}:

python3.pkgs.buildPythonApplication rec {
  pname = "javascript";
  version = "1.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "extremeheat";
    repo = "JSPyBridge";
    rev = version;
    hash = "sha256-6wdIsKchzoyDwf7VNaX6MTqu66PdnJLwILSwpxKcvN4=";
  };

  patches = [
    # https://github.com/extremeheat/JSPyBridge/issues/117
    # site-packages should be treated as read-only
    ./expose-cache-path.patch
  ];

  postPatch = ''
    substituteInPlace src/javascript/connection.py \
      --replace ' else "node"' ' else "${nodejs}/bin/node"'

    substituteInPlace src/javascript/js/deps.js \
      --replace "'npm'" "'${nodejs}/bin/npm'"
  '';

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = [
    nodejs
  ];

  pythonImportsCheck = [ "javascript" ];

  meta = with lib; {
    description = "Bridge to interoperate Node.js and Python";
    homepage = "https://github.com/extremeheat/JSPyBridge";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "js-py-bridge";
  };
}
