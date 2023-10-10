{
  lib,
  ajpy,
  buildPythonPackage,
  dnspython,
  fetchPypi,
  impacket,
  ipy,
  mysqlclient,
  paramiko,
  psycopg2,
  pyasn1,
  pycrypto,
  pycurl,
  pyopenssl,
  pysnmp,
  pysqlcipher3,
  pythonOlder,
  enableUnfree ? false,
  cx_oracle,
}:
buildPythonPackage rec {
  pname = "patator";
  version = "1.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VQ7JPyQOY9X/7LVAvTwftoOegt4KyfERgu38HfmsYDM=";
  };

  postPatch =
    ''
      substituteInPlace requirements.txt \
        --replace psycopg2-binary psycopg2 \
        --replace pysnmp==4.4.12 pysnmp \
        --replace pyasn1==0.4.8 pyasn1
    ''
    + lib.optionalString (!enableUnfree)
    ''
      substituteInPlace requirements.txt \
        --replace cx_Oracle ""
    '';

  propagatedBuildInputs =
    [
      ajpy
      dnspython
      impacket
      ipy
      mysqlclient
      paramiko
      psycopg2
      pyasn1
      pycrypto
      pycurl
      pyopenssl
      pysnmp
      pysqlcipher3
    ]
    ++ lib.optional enableUnfree [
      cx_oracle
    ];

  # tests require docker-compose and vagrant
  doCheck = false;

  postInstall = ''
    mv -v $out/bin/patator.py $out/bin/patator
  '';

  meta = with lib; {
    description = "Multi-purpose brute-forcer";
    homepage = "https://github.com/lanjelot/patator";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [];
  };
}
