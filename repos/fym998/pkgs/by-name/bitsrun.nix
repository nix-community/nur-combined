{
  python3Packages,
  fetchPypi,
}:
with python3Packages;
buildPythonApplication (finalAttrs: {
  pname = "bitsrun";
  version = "3.7.1";
  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-HYJPnHv4q0sECiHiGHPgm3LRnkmUlgCZ4KLq/GyLu/A=";
  };
  pyproject = true;
  build-system = [ setuptools ];
  dependencies = [
    httpx
    socksio
    rich
    humanize
    click
    platformdirs
  ];
  meta = {
    homepage = "https://github.com/BITNP/bitsrun";
    description = "A headless login / logout script for 10.0.0.55 at BIT.";
  };
})
