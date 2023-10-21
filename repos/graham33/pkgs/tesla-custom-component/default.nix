{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "tesla-custom-component";
  version = "3.18.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "tesla";
    rev = "v${version}";
    sha256 = "sha256-MjY0IILJYu4zZ9Ab0zHocX1F6Q8asfRYzpJEzXJxoWY=";
  };

  patches = [ ./poetry.patch ];

  postPatch = ''
     substituteInPlace pyproject.toml \
      --replace 'teslajsonpy = "3.9.5"' 'teslajsonpy = ">=3.9.5"'
     substituteInPlace custom_components/tesla_custom/manifest.json \
      --replace 'teslajsonpy==3.9.5' 'teslajsonpy>=3.9.5'
 '';

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    setuptools
    teslajsonpy
  ];

  fixupPhase = ''
    mkdir -p $out/custom_components
    mv $out/${home-assistant.python.sitePackages}/* $out/custom_components/
    rm -r $out/lib
  '';

  meta = with lib; {
    homepage = "https://github.com/alandtse/tesla";
    license = licenses.asl20;
    description = "A fork of the official Tesla integration in Home Assistant.";
    maintainers = with maintainers; [ graham33 ];
  };
}
