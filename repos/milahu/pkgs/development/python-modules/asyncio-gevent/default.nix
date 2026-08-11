{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pdm-backend,
  gevent,
  greenlet,
}:

buildPythonPackage (finalAttrs: {
  pname = "asyncio-gevent";
  version = "0.2.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gfmio";
    repo = "asyncio-gevent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V9ffqyu6bC9Abe/QGREwXWHNH6magC+E1vWy/+Qhsos=";
  };

  build-system = [
    pdm-backend
  ];

  dependencies = [
    gevent
    greenlet
  ];

  pythonImportsCheck = [
    "asyncio_gevent"
  ];

  meta = {
    description = "Asyncio & gevent in harmony";
    homepage = "https://github.com/gfmio/asyncio-gevent";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
