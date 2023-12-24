{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, pythonRelaxDepsHook
, pytestCheckHook
  #, aliyun-python-sdk-actiontrail
  #, aliyun-python-sdk-core
  #, aliyun-python-sdk-ecs
  #, aliyun-python-sdk-kms
  #, aliyun-python-sdk-ocs
  #, aliyun-python-sdk-ram
  #, aliyun-python-sdk-rds
  #, aliyun-python-sdk-sts
  #, aliyun-python-sdk-vpc
, asyncio-throttle
, azure-identity
, azure-mgmt-authorization
, azure-mgmt-compute
, azure-mgmt-keyvault
, azure-mgmt-monitor
, azure-mgmt-network
, azure-mgmt-rdbms
, azure-mgmt-redis
, azure-mgmt-resource
, azure-mgmt-security
, azure-mgmt-sql
, azure-mgmt-storage
, azure-mgmt-web
, boto3
, botocore
, cherrypy
, cherrypy-cors
, coloredlogs
, google-api-python-client
, google-cloud-container
, google-cloud-core
, google-cloud-iam
, google-cloud-kms
, google-cloud-logging
, google-cloud-monitoring
, google-cloud-resource-manager
, google-cloud-storage
, grpcio
, httplib2shim
, kubernetes
, msgraph-core
, netaddr
, oauth2client
, oci
, oss2
, policyuniverse
, python-dateutil
, sqlitedict
}:
buildPythonPackage rec {
  name = "scoutsuite";
  version = "5.13.0";
  owner = "nccgroup";
  repo = name;
  format = "setuptools";

  src = fetchFromGitHub {
    inherit owner repo;
    rev = version;
    sha256 = "sha256-G76Xi1Tv4sY9S5UFt2H0Bu+eF/7iIgE8+Dba0FpQ/P4=";
  };

  propagatedBuildInputs = [
    # Disable Aliyun due to many deps not packaged in nix
    #aliyun-python-sdk-actiontrail
    #aliyun-python-sdk-core
    #aliyun-python-sdk-ecs
    #aliyun-python-sdk-kms
    #aliyun-python-sdk-ocs
    #aliyun-python-sdk-ram
    #aliyun-python-sdk-rds
    #aliyun-python-sdk-sts
    #aliyun-python-sdk-vpc
    asyncio-throttle
    azure-identity
    azure-mgmt-authorization
    azure-mgmt-compute
    azure-mgmt-keyvault
    azure-mgmt-monitor
    azure-mgmt-network
    azure-mgmt-rdbms
    azure-mgmt-redis
    azure-mgmt-resource
    azure-mgmt-security
    azure-mgmt-sql
    azure-mgmt-storage
    azure-mgmt-web
    boto3
    botocore
    cherrypy
    cherrypy-cors
    coloredlogs
    google-api-python-client
    google-cloud-container
    google-cloud-core
    google-cloud-iam
    google-cloud-kms
    google-cloud-logging
    google-cloud-monitoring
    google-cloud-resource-manager
    google-cloud-storage
    grpcio
    httplib2shim
    kubernetes
    msgraph-core
    netaddr
    oauth2client
    oci
    oss2
    policyuniverse
    python-dateutil
    sqlitedict
  ];

  postPatch = ''
    # Disable aliyun support
    sed -i -e "/^aliyun.*/d" requirements.txt
    rm -rf ScoutSuite/providers/aliyun
    rm -rf ScoutSuite/output/data/html/{summaries,partials}/aliyun
    sed -i -e "/^recursive-include ScoutSuite\/providers\/aliyun/d" MANIFEST.in
    sed -i -e "/.*self._init_aliyun_parser().*/d" ScoutSuite/core/cli_parser.py

    # Import bug in this script
    sed -i -e "s/from utils/from tools.utils/g" tools/format_findings.py
  '';

  nativeBuildInputs = [
    pythonRelaxDepsHook
    pytestCheckHook
  ];
  pythonRelaxDeps = true;

  preBuild = ''
    # Modify requirements directly, since consumed by setup.py
    substituteInPlace requirements.txt \
      --replace "python-dateutil<2.8.1,>=2.1" "python-dateutil"
    sed -i -e "s/^\(.*\)[<=>]=.*/\1/" requirements.txt
  '';

  preCheck = ''
    mkdir -p testsbase

    # Fix assumed static python script
    sed -i -e "s|./scout\.py|$out/bin/scout|g" tests/*.py
  '';

  pytestFlagsArray = [
    "tests/"
  ];

  disabledTests = [
    # We change help output by disabling aliyun
    "test_argument_parser"
  ];

  meta = {
    homepage = "https://github.com/nccgroup/scoutsuite";
    changelog = "https://github.com/nccgroup/scoutsuite/tag/v${version}";
    description = "Multi-Cloud Security Auditing Tool";
    longDescription = ''
    '';
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ jpts ];
    platforms = lib.platforms.unix;
  };
}
