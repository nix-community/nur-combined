{ lib
, fetchFromGitLab
, home-assistant
}:

let
  python312 = home-assistant.passthru.python;
  hydroqc = python312.pkgs.callPackage ./hydro-quebec-api-wrapper.nix { };
  mqtt-hass-base = python312.pkgs.callPackage ./mqtt-hass-base.nix { };
  version = "2.0.0";
in

python312.pkgs.buildPythonApplication rec {
  pname = "hydroqc2mqtt";
  inherit version;
  pyproject = true;

  src = fetchFromGitLab {
    owner = "hydroqc";
    repo = "hydroqc2mqtt";
    rev = version;
    hash = "sha256-c6idfbeUAajOyb8e+tNncj9FT8QlmBTCP1P+80tSdOA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "setuptools==69.5.1" "setuptools"
    substituteInPlace pyproject.toml --replace-fail "setuptools_scm[toml]==8.1.0" "setuptools_scm[toml]"
    substituteInPlace pyproject.toml --replace-fail "wheel==0.43.0" "wheel"

    sed -i 's/setuptools[~=]/setuptools>/' pyproject.toml
    sed -i 's/wheel[~=]/wheel>/' pyproject.toml
  '';

  dependencies = with python312.pkgs; [
    hydroqc
    mqtt-hass-base
    homeassistant
    charset-normalizer
    aiomqtt
  ];

  nativeBuildInputs = with python312.pkgs; [
    setuptools
    setuptools-scm
    wheel
    pythonRelaxDepsHook
  ];

  pythonRelaxDeps = true; 

  pythonImportsCheck = [ "hydroqc2mqtt" ];

  passthru = {
    inherit mqtt-hass-base hydroqc;
  };

  meta = with lib; {
    description = "MQTT daemon that sends your Hydro-Quebec account information to your MQTT server for consumption by Home-Assistant or other home automation platforms.\r\n\r\nDocs: [https://hydroqc.ca](https://hydroqc.ca";
    homepage = "https://gitlab.com/hydroqc/hydroqc2mqtt";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "hydroqc2mqtt";
    platforms = platforms.linux;
  };
}
