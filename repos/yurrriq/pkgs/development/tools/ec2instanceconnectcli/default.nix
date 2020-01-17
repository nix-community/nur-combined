{ stdenv, buildPythonPackage, fetchPypi, boto3 }:

buildPythonPackage rec {
  pname = "ec2instanceconnectcli";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1s4xya5ddlv9vbbn62lhcspl4g1fjqhh5nq2snbmliqssmw8r0fw";
  };

  propagatedBuildInputs = [ boto3 ];

  meta = with stdenv.lib; {
    description = "Command Line Interface for AWS EC2 Instance Connect";
    license = licenses.apsl20;
    homepage = https://aws.amazon.com/cli/;
  };
}
