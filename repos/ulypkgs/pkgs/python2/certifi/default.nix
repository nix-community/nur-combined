{
  lib,
  fetchFromGitHub,
  fetchPypi,
  buildPythonPackage,
}:

buildPythonPackage (finalAttrs: {
  pname = "certifi";
  version = "2019.11.28";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-JbZMfaTNdHlZTQNcCMLYCetKqzom5amQ6pjMRQwyDx8=";
  };

  certifiSrc = fetchFromGitHub {
    owner = "certifi";
    repo = "python-certifi";
    rev = "2021.10.08";
    hash = "sha256-SFb/spVHK15b53ZG1P147DcTjs1dqR0+MBXzpE+CWpo=";
  };

  postPatch = ''
    cp ${finalAttrs.certifiSrc}/certifi/cacert.pem certifi/cacert.pem
  '';

  pythonImportsCheck = [ "certifi" ];

  # no tests implemented
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/certifi/python-certifi";
    description = "Python package for providing Mozilla's CA Bundle";
    license = licenses.isc;
    maintainers = with maintainers; [ ]; # NixOps team
  };
})
