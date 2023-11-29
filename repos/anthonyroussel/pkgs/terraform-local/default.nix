{ lib
, python3
, fetchPypi
, terraform
}:

python3.pkgs.buildPythonApplication rec {
  pname = "terraform-local";
  version = "0.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1FaYAXLuxu3tQkm/BIccCql/boSV5g7LwlT//h4wT4k=";
  };

  propagatedBuildInputs = [
    python3.pkgs.localstack-client
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
