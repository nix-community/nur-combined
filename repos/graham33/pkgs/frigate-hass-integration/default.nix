{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "frigate-hass-integration";
  version = "4.0.0";
  format = "other"; # has pyproject.toml but no build system defined

  src = fetchFromGitHub {
    owner = "blakeblackshear";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-8td0SGyAM5HFD3Q5C1WxTLu6xqgAgnnpi+xid8OAjSQ=";
  };

  postPatch = ''
    substituteInPlace custom_components/frigate/manifest.json \
      --replace 'pytz==2022.7' 'pytz>=2022.7'
  '';

  propagatedBuildInputs = [
    pytz
  ];

  installPhase = ''
    mkdir -p $out
    cp -r custom_components $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/blakeblackshear/frigate-hass-integration";
    license = licenses.mit;
    description = "Frigate Home Assistant integration";
    maintainers = with maintainers; [ graham33 ];
  };
}
