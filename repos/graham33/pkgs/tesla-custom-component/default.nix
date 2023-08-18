{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "tesla-custom-component";
  version = "3.15.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "tesla";
    rev = "v${version}";
    sha256 = "sha256-T2IjDX8zwD4iUZcP0gl8O66Q0vrwXQx8LA58EQei4nA=";
  };

  patches = [ ./poetry.patch ];

  postPatch = ''
     substituteInPlace pyproject.toml \
      --replace 'version = "3.15.1"' 'version = "3.15.2"' \
      --replace 'teslajsonpy = "3.9.0"' 'teslajsonpy = "3.9.2"'
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
