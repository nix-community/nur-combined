{ lib, buildPythonApplication, fetchPypi, pyyaml, xmltodict, argcomplete, jq }:

buildPythonApplication rec {
  pname = "yq";
  version = "2.10.0";

  propagatedBuildInputs = [ pyyaml xmltodict argcomplete jq ];

  # ModuleNotFoundError: No module named 'test.test'
  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    sha256 = "0ims5q3kfykbyxdfwc3lsrhbcnpgdl56p5rfhpp8vhzi503jrbxb";
  };

  meta = with lib; {
    description = "Command-line YAML processor - jq wrapper for YAML documents.";
    homepage = https://github.com/kislyuk/yq;
    license = [ licenses.asl20 ];
    maintainers = [ maintainers.womfoo ];
  };
}
