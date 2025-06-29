{ lib, python3Packages, fetchFromGitLab, ansible, python-grid5000, iotlabsshcli, enoslib-ansible
, distem, iotlabcli }:

python3Packages.buildPythonPackage rec {
  pname = "enoslib";
  version = "10.1.0";
  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = "discovery";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-q/84AaaZLZklvlXsl8cNHZRXK3fzmM2b4c0EylH+GPw=";
  };

  propagatedBuildInputs = with python3Packages;
    [ cryptography ansible sshtunnel rich jsonschema packaging ipywidgets ] ++ [
      python-grid5000
      enoslib-ansible
    ] ++ optional-dependencies.all ++ optional-dependencies.chameleon
    ++ optional-dependencies.iotlab ++ optional-dependencies.vagrant
    ++ optional-dependencies.distem;

  optional-dependencies = lib.fix (self: {
    all = self.chameleon ++ self.iotlab ++ self.vagrant ++ self.distem;
    chameleon = [
      # TODO: Package those packages
      # python-chi
      # python-glanceclient
      # python-openstackclient
      # python-neutronclient
      # python-blazarclient
      # # python-chi do not constraint its dependencies
      # python-cinderclient
      # openstacksdk
    ];
    iotlab = [ iotlabcli iotlabsshcli ];
    vagrant = with python3Packages; [ python-vagrant ];
    distem = [ distem ];
  });
}
