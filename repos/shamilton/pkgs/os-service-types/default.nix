{ lib
, buildPythonPackage
, fetchPypi
, pbr
, six
}:
let 
  pyModuleDeps = [
    pbr
    six
  ];
in
buildPythonPackage rec {
  pname = "os-service-types";
  version = "1.7.0";

  src = fetchPypi {
    pname = "os-service-types";
    inherit version;
    sha256 = "0v4chwr5jykkvkv4w7iaaic7gb06j6ziw7xrjlwkcf92m2ch501i";
  };
  
  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps;
  
  # Needs internet connection
  doCheck = false;

  meta = with lib; {
    description = "Python library for consuming OpenStack sevice-types-authority data";
    license = licenses.asl20;
    longDescription = ''
      The data is in JSON and the latest data should always be used. This
      simple library exists to allow for easy consumption of the data, along
      with a built-in version of the data to use in case network access is for
      some reason not possible and local caching of the fetched data.
    '';
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
