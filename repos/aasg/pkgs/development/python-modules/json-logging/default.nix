{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
, wheel
, flask
, connexion
, sanic
, fastapi
, uvicorn
, requests
}:

buildPythonPackage rec {
  pname = "json-logging";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "bobbui";
    repo = "json-logging-python";
    rev = version;
    hash = "sha256-0eIhOi30r3ApyVkiBdTQps5tNj7rI+q8TjNWxTnhtMQ=";
  };
  postPatch = ''
    # Fix dependency detection for tests.  `import quart` finds
    # tests/smoketests/quart instead of the quart package.
    sed -i json_logging/framework/quart/__init__.py -r \
      -e 's/^(\s*)import quart$/\1from quart import Quart/'

    # Don't try to find tests in __pycache__.
    substituteInPlace tests/smoketests/test_run_smoketest.py \
      --replace "folder.is_dir()" "folder.is_dir() and folder.name != '__pycache__'"
  '';

  # - Quart is not packaged for Nixpkgs.
  # - FastAPI is broken, see github:NixOS/nixpkgs#112701 and github:tiangolo/fastapi#2335.
  # - Tests for Sanic rely on Request.ctx, introduced in Sanic 19.9.
  checkInputs = [ wheel flask connexion /*quart*/ sanic /*fastapi*/ uvicorn requests pytestCheckHook ];
  disabledTests = [ "quart" "fastapi" ]
    ++ lib.optional (lib.versionOlder sanic.version "19.9.0") "sanic";
  # TODO: replace post NixOS 20.09 with disabledTestPaths
  pytestFlagsArray = [ "--ignore=tests/test_fastapi.py" ];
  # Tests spawn servers and try to connect to them.
  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    description = "JSON Python logging";
    longDescription = ''
      Python logging library to emit JSON log that can be easily indexed and searchable by logging infrastructure such as ELK, EFK, AWS Cloudwatch, GCP Stackdriver.
    '';
    homepage = "https://github.com/bobbui/json-logging-python";
    license = licenses.asl20;
    platforms = platforms.all;
    maintainers = with maintainers; [ AluisioASG ];
  };
}
