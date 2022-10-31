{ lib
, python3Packages
, terraform
}:

python3Packages.buildPythonApplication rec {
  pname = "terraform-local";
  version = "0.6";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-1FaYAXLuxu3tQkm/BIccCql/boSV5g7LwlT//h4wT4k=";
  };

  propagatedBuildInputs = [
    python3Packages.localstack-client
    terraform
  ];

  checkPhase = ''
    $out/bin/tflocal -version
  '';

  meta = with lib; {
    description = "Small wrapper script to run Terraform against LocalStack";
    license = licenses.apsl20;
    maintainers = with maintainers; [ anthonyroussel ];
    homepage = "https://github.com/localstack/terraform-local";
  };
}
