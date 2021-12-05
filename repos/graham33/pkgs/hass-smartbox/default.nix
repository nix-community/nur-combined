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
  version = "0.8.0-pre39c4f64";
  format = "other";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    #rev = "v${version}";
    rev = "39c4f648bcf25a7d922293a3d99d0c34b016dbb6";
    sha256 = "sha256:0j52mwp8hq15jrdqrr9v304mb6n2jj6qpigs5z1v7kw2bqffcrkb";
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
