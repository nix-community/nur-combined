{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, python
, poetry-core
, setuptools
, teslajsonpy
}:

buildHomeAssistantComponent rec {
  owner = "graham33";
  domain = "tesla_custom";
  version = "3.24.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "tesla";
    rev = "v${version}";
    sha256 = "sha256-oKCfGwMyPzPhUP8XkGWvFEy2uEfP4QvcEpH1GbH7EB8=";
  };

  patches = [ ./poetry.patch ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'teslajsonpy = "3.12.0"' 'teslajsonpy = ">=3.12.0"'
    substituteInPlace custom_components/tesla_custom/manifest.json \
      --replace 'teslajsonpy==3.12.0' 'teslajsonpy>=3.12.0'
  '';

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    setuptools
    teslajsonpy
  ];

  installPhase = ''
    pypaInstallPhase
  '';

  fixupPhase = ''
    mkdir -p $out/custom_components
    mv $out/${python.sitePackages}/* $out/custom_components/
    rm -r $out/lib
  '';

  meta = with lib; {
    homepage = "https://github.com/alandtse/tesla";
    license = licenses.asl20;
    description = "A fork of the official Tesla integration in Home Assistant.";
    maintainers = with maintainers; [ graham33 ];
  };
}
