{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "bounded-pool-executor";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "mowshon";
    repo = "bounded_pool_executor";
    rev = "24b5a36ec4997c23ef377559ace6b3599af0f018";
    hash = "sha256-83xdIz94C7BjU+2zubt1tcFVnRF0F9DSDrCYzPBLmVk=";
  };

  pythonImportsCheck = [ "bounded_pool_executor" ];

  meta = {
    description = "Bounded Process&Thread Pool Executor";
    homepage = "https://github.com/mowshon/bounded_pool_executor";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
