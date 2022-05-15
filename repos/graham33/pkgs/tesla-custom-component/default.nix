{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "tesla-custom-component";
  version = "2.2.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "tesla";
    rev = "v${version}";
    sha256 = "0507lq8jpf032sxqjf5j4bcyjylf40bz589298lk30f29aldqvrk";
  };

 postPatch = ''
   substituteInPlace pyproject.toml --replace \
     'teslajsonpy = "^2.1.0"' 'teslajsonpy = ">=2.1.0"'
   substituteInPlace custom_components/tesla_custom/manifest.json --replace \
     "teslajsonpy==2.1.0" "teslajsonpy>=2.1.0"
 '';

  patches = [ ./poetry.patch ];

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
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
