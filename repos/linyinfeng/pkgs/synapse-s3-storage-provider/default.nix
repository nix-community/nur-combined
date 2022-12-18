{ sources, lib, python3Packages }:

python3Packages.buildPythonPackage rec {
  inherit (sources.synapse-s3-storage-provider) pname version src;

  postPatch = ''
    # use latest pyyaml and humanize (used in media-upload)
    substituteInPlace setup.py \
      --replace "PyYAML>=5.4,<6.0" "PyYAML" \
      --replace "humanize>=0.5.1,<0.6" "humanize"
  '';

  propagatedBuildInputs = with python3Packages; [
    boto3
    botocore
    humanize
    psycopg2
    pyyaml
    tqdm
    twisted
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com//matrix-org/synapse-s3-storage-provider";
    description = "Synapse storage provider to fetch and store media in Amazon S3";
    license = licenses.asl20;
    maintainers = with maintainers; [ yinfeng ];
  };
}
