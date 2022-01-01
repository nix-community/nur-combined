{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "tesla-custom-component";
  version = "1.4.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "tesla";
    rev = "v${version}";
    sha256 = "1nl9ghasy222n9mkm0q7glljfbsfa2y6kvbfq5260zfsiw3n1ik2";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace \
      'teslajsonpy = "^1.4.1"' \
      'teslajsonpy = ">=1.4.1"'
    substituteInPlace custom_components/tesla_custom/manifest.json --replace \
      "teslajsonpy==1.4.1" \
      "teslajsonpy>=1.4.1"
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
