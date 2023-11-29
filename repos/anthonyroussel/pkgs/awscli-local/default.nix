{ lib
, python3
, fetchPypi
, awscli2
, substituteAll
}:

let
  py = python3 // {
    pkgs = python3.pkgs.overrideScope (final: prev: {
      urllib3 = prev.urllib3.overridePythonAttrs (prev: rec {
        pyproject = true;
        version = "1.26.18";
        nativeBuildInputs = with final; [
          setuptools
        ];
        src = prev.src.override {
          inherit version;
          hash = "sha256-+OzBu6VmdBNFfFKauVW/jGe0XbeZ0VkGYmFxnjKFgKA=";
        };
      });
    });
  };

in
py.pkgs.buildPythonApplication rec {
  pname = "awscli-local";
  version = "0.20";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-hpREX0/PEeHtFcDPRxULhfWQTMbyeugVcEO4nPn0sWo=";
  };

  propagatedBuildInputs = with py.pkgs; [
    localstack-client
  ];

  patches = [
    # hardcode paths to aws in awscli2 package
    (substituteAll {
      src = ./fix-paths.patch;
      aws = "${awscli2}/bin/aws";
    })
  ];

  checkPhase = ''
    $out/bin/awslocal -h
    $out/bin/awslocal --version
  '';

  meta = with lib; {
    description = "Thin wrapper around the AWS command line interface for use with LocalStack";
    license = licenses.apsl20;
    maintainers = with maintainers; [ anthonyroussel ];
    homepage = "https://github.com/localstack/awscli-local";
  };
}
