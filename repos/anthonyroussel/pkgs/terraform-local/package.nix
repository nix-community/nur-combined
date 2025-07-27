{
  lib,
  fetchPypi,
  python3Packages,
  terraform,
}:

python3Packages.buildPythonApplication rec {
  pname = "terraform-local";
  version = "0.24.1";
  pyproject = true;

  src = fetchPypi {
    pname = "terraform_local";
    inherit version;
    hash = "sha256-LPrrKDoXUwg/P1m+Gi4I0iUoaRNjNpTWlbBLupkTrpE=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies =
    with python3Packages;
    [
      localstack-client
      python-hcl2
    ]
    ++ [ terraform ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/tflocal -version
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Small wrapper script to run Terraform against LocalStack";
    license = licenses.asl20;
    maintainers = with maintainers; [ anthonyroussel ];
    homepage = "https://github.com/localstack/terraform-local";
  };
}
