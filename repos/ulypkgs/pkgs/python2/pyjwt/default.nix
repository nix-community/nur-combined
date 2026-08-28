{
  lib,
  buildPythonPackage,
  fetchPypi,
  cryptography,
  ecdsa,
  pytestCheckHook,
  pythonOlder,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyjwt";
  version = "1.7.1";

  src = fetchPypi {
    pname = "PyJWT";
    inherit (finalAttrs) version;
    hash = "sha256-jVmpdvt3Pz5qOchWNjV8Tw4kJwc5TK2t2YFPXLqiDpY=";
  };

  postPatch = ''
    sed -i '/^addopts/d' setup.cfg
  '';

  propagatedBuildInputs = [
    cryptography
    ecdsa
  ];

  checkInputs = [
    pytestCheckHook
  ];

  disabledTests = [
    "test_ec_verify_should_return_false_if_signature_invalid"
  ];

  pythonImportsCheck = [ "jwt" ];

  meta = with lib; {
    description = "JSON Web Token implementation in Python";
    homepage = "https://github.com/jpadilla/pyjwt";
    license = licenses.mit;
  };
})
