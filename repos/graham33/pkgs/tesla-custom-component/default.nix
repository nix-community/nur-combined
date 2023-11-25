{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, python
, poetry-core
, setuptools
, teslajsonpy
}:

buildHomeAssistantComponent rec {
  pname = "tesla-custom-component";
  version = "3.19.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "tesla";
    rev = "v${version}";
    sha256 = "sha256-lcaQr3pnWwzjmHSFSMgzq7oSYBJgeoFHsCjW61j8zsM=";
  };

  patches = [ ./poetry.patch ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'teslajsonpy = "3.9.6"' 'teslajsonpy = ">=3.9.6"'
    substituteInPlace custom_components/tesla_custom/manifest.json \
      --replace 'teslajsonpy==3.9.6' 'teslajsonpy>=3.9.6'
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
