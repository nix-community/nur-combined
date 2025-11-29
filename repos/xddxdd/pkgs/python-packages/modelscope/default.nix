{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  addict,
  attrs,
  datasets,
  einops,
  oss2,
  pillow,
  python-dateutil,
  requests,
  scipy,
  setuptools,
  simplejson,
  sortedcontainers,
  tqdm,
  transformers,
  urllib3,
}:
buildPythonPackage rec {
  inherit (sources.modelscope) pname version src;
  pyproject = true;

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    addict
    attrs
    datasets
    einops
    oss2
    pillow
    python-dateutil
    requests
    scipy
    simplejson
    sortedcontainers
    tqdm
    transformers
    urllib3
  ];

  pythonImportsCheck = [ "modelscope" ];

  meta = {
    changelog = "https://github.com/modelscope/modelscope/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Bring the notion of Model-as-a-Service to life";
    homepage = "https://www.modelscope.cn/";
    license = with lib.licenses; [ asl20 ];
    mainProgram = "modelscope";
  };
}
