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
  version = "3.19.5";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "tesla";
    rev = "v${version}";
    sha256 = "sha256-6qdfCK35s423NwecIsaxLpS0EwqcJ2HRe/Lpa02qF3k=";
  };

  patches = [ ./poetry.patch ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'teslajsonpy = "3.9.8"' 'teslajsonpy = ">=3.9.8"'
    substituteInPlace custom_components/tesla_custom/manifest.json \
      --replace 'teslajsonpy==3.9.8' 'teslajsonpy>=3.9.8'
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
