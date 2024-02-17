{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "python-qpid-proton";
  version = "0.39.0";
  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-NiBVrmq0x/FDckfGAnV/MDKNVcCmmG1baMqXmN6fzgI=";
  };
  format = "pyproject";

  nativeBuildInputs = with python3Packages; [
    setuptools
    cffi
  ];
  pythonImportsCheck = [ "proton" ];

  meta = with lib; {
    description = "An AMQP based messaging library";
    longDescription = ''
      Python binding to the Proton AMQP messaging toolkit.

      Qpid Proton is a high-performance, lightweight messaging
      library. It can be used in the widest range of messaging
      applications, including brokers, client libraries, routers,
      bridges, proxies, and more. Proton makes it trivial to integrate
      with the AMQP 1.0 ecosystem from any platform, environment, or
      language.
    '';
    homepage = "https://qpid.apache.org/proton/";
    maintainers = with maintainers; [ javimerino ];
    license = [ licenses.asl20 ];
    platforms = platforms.all;
  };
}
