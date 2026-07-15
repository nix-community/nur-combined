{
  lib,
  buildPythonPackage,
  docstring-parser,
  fetchFromGitHub,
  httpx,
  jsonschema,
  pydantic,
  callPackage,
  websockets,
}:

let
  uv-build = callPackage ./uv-build.nix { };
in
buildPythonPackage rec {
  pname = "pctx-client";
  version = "0.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "portofcontext";
    repo = "pctx";
    rev = "pctx-py-v${version}";
    hash = "sha256-0+Ql9I3OnQ/VpcNjQsj0Zv3zgTGLlel87DlfEUJ/WWo=";
  };

  sourceRoot = "source/pctx-py";
  postPatch = ''
    data_dir=src/pctx_client/descriptions/data
    if [ -L "$data_dir" ]; then
      data_target="$(readlink "$data_dir")"
      data_parent="$(dirname "$data_dir")"
      rm "$data_dir"
      cp -r "$data_parent/$data_target" "$data_dir"
    fi
  '';
  build-system = [ uv-build ];
  dependencies = [
    docstring-parser
    httpx
    jsonschema
    pydantic
    websockets
  ];

  pythonImportsCheck = [ "pctx_client" ];
  doCheck = false;

  meta = with lib; {
    description = "Python client for using Code Mode via PCTX";
    homepage = "https://github.com/portofcontext/pctx";
    license = licenses.mit;
  };
}
