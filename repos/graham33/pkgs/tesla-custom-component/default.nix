{ stdenv
, buildPythonPackage
, python
, fetchFromGitHub
, teslajsonpy
}:

buildPythonPackage rec {
  pname = "tesla-custom-component";
  version = "0.1.5";
  format = "other";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "tesla";
    rev = "v${version}";
    sha256 = "09pb9x3gbrcr9583clhgyd3bzg3ljj7pragimiy1yzlw7hswhmsy";
  };

  propagatedBuildInputs = [
    teslajsonpy
  ];

  installPhase = ''
    mkdir -p $out/custom_components
    cp -r custom_components/tesla_custom $out/custom_components/
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    ${python.interpreter} ${../build-support/ha-custom-components/check_requirements.py} $out/custom_components/tesla_custom/manifest.json
  '';
}
