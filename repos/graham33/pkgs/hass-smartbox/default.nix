{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, homeassistant
, smartbox
, voluptuous
, pytest-aiohttp
, pytest-asyncio
, pytest-cov
, pytest-homeassistant-custom-component
, pytest-randomly
, pytest-sugar
, pytestCheckHook
, haManifestRequirementsCheckHook
}:

buildPythonPackage rec {
  pname = "hass-smartbox";
  version = "0.5.0";
  format = "other";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "v${version}";
    sha256 = "1id4xndagvvsy7srqj55gykc519c6ar2l4rnci3iq0sax4i1xmxw";
  };

  propagatedBuildInputs = [
    homeassistant
    smartbox
    voluptuous
  ];

  installPhase = ''
    mkdir -p $out/custom_components
    cp -r custom_components/smartbox $out/custom_components/
  '';

  doCheck = true;

  checkInputs = [
    pytest-aiohttp
    pytest-asyncio
    pytest-cov
    pytest-homeassistant-custom-component
    pytest-randomly
    pytest-sugar
    pytestCheckHook
    haManifestRequirementsCheckHook
  ];

  meta = with lib; {
    homepage = "https://github.com/graham33/hass-smartbox";
    license = licenses.mit;
    description = "Home Assistant integration for heating smartboxes.";
    maintainers = with maintainers; [ graham33 ];
  };
}
