{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tinyflux";
  version = "1.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "citrusvanilla";
    repo = "tinyflux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WCLxyW/Ep076U8DxCL9D20XYWsQl4uDc+RyZXn22Q7A=";
  };

  postPatch = ''
    echo ${finalAttrs.version} > version.txt
  '';

  build-system = with python3Packages; [ setuptools ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "The tiny time series database";
    homepage = "https://github.com/citrusvanilla/tinyflux";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
