{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "tesla-custom-component";
  version = "3.0.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "tesla";
    rev = "v${version}";
    sha256 = "sha256-KaO7GmBQl4dwwNFb+YGv5/lALZ31P+Pvt/jNxLyfmE0=";
  };

 postPatch = ''
   substituteInPlace pyproject.toml --replace \
     'teslajsonpy = "^3.0.0"' 'teslajsonpy = ">=3.0.0"'
   substituteInPlace custom_components/tesla_custom/manifest.json --replace \
     "teslajsonpy==3.0.0" "teslajsonpy>=3.0.0"
 '';

  patches = [ ./poetry.patch ];

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
