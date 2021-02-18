{ lib
, buildPythonPackage
, fetchFromGitHub
, aiohttp
, beautifulsoup4
, importlib-metadata
, multidict
, poetry
, pytestCheckHook
, pythonAtLeast
, pythonOlder
, typer
, yarl
}:

buildPythonPackage rec {
  pname = "authcaptureproxy";
  version = "0.4.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "auth_capture_proxy";
    rev = "v${version}";
    sha256 = "1b0m94i1ycna3prlf2qkng6dsvfy3l4hvjncqvfivp1lqmhwx7c0";
  };

  patchPhase = if pythonAtLeast "3.8" then ''
    sed -i '/importlib-metadata/d' pyproject.toml
  '' else ''
    sed -i 's/importlib-metadata = "^3.4.0"/importlib-metadata = "^1.7.0"/' pyproject.toml
  '';

  nativeBuildInputs = [
    poetry
  ];

  propagatedBuildInputs = [
    aiohttp
    beautifulsoup4
    multidict
    typer
    yarl
  ] ++ lib.optionals (pythonOlder "3.8") [ importlib-metadata ];

  checkInputs = [ pytestCheckHook ];

  meta = with lib; {
    homepage = "https://github.com/alandtse/auth_capture_proxy";
    license = licenses.asl20;
    description = "A Python project to create a proxy to capture authentication information from a webpage.";
    # TODO: maintainer
    #maintainers = with maintainers; [ graham33 ];
  };
}
