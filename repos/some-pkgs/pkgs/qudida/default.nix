{ lib
, buildPythonPackage
, fetchFromGitHub
, numpy
, scikit-learn
, typing-extensions
, opencv4
, pytestCheckHook
, qudida
}:

let
  pname = "qudida";
  version = "0.0.4";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "arsenyinfo";
    repo = pname;
    rev = version;
    hash = "sha256-4XQAdbqV6vRdwUDDdrilV9D8mGTUXUzPBWcX9LMwlvQ=";
  };

  postPatch = ''
    sed -i 's/install_requires=get_install.*$/install_requires=INSTALL_REQUIRES + ["opencv"],/' setup.py 
  '';

  propagatedBuildInputs = [
    numpy
    scikit-learn
    typing-extensions
    opencv4
  ];

  checkInputs = [
    pytestCheckHook
  ];

  doCheck = false;
  passthru.tests.pytest = qudida.overridePythonAttrs (_: { doCheck = true; });

  pythonImportsCheck = [ "qudida" ];

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.mit;
    description = "QUick and DIrty Domain Adaptation";
    homepage = "https://github.com/arsenyinfo/qudida";
    platforms = lib.platforms.unix;
  };
}
