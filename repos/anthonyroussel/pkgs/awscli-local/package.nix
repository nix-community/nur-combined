{
  lib,
  awscli2,
  fetchPypi,
  python3,
  replaceVars,
}:

let
  py = python3 // {
    pkgs = python3.pkgs.overrideScope (
      final: prev: {
        urllib3 = prev.urllib3.overridePythonAttrs (prev: rec {
          version = "1.26.18";
          nativeBuildInputs = with final; [
            setuptools
          ];
          postPatch = null;
          src = prev.src.override {
            inherit version;
            hash = "sha256-+OzBu6VmdBNFfFKauVW/jGe0XbeZ0VkGYmFxnjKFgKA=";
          };
        });
      }
    );
  };

in
py.pkgs.buildPythonApplication rec {
  pname = "awscli-local";
  version = "0.22.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-OAfPLuS73U3038i+8CfyW95SPcr4EZcg9nftleu6ZqQ=";
  };

  build-system = with py.pkgs; [
    setuptools
  ];

  dependencies = with py.pkgs; [
    localstack-client
  ];

  patches = [
    # hardcode paths to aws in awscli2 package
    (replaceVars ./fix-paths.patch {
      aws = "${awscli2}/bin/aws";
    })
  ];

  nativeCheckInputs = with py.pkgs; [
    pytestCheckHook
  ];

  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/awslocal -h
    $out/bin/awslocal --version
    runHook postInstallCheck
  '';

  meta = {
    description = "Thin wrapper around the AWS command line interface for use with LocalStack";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.anthonyroussel ];
    homepage = "https://github.com/localstack/awscli-local";
  };
}
