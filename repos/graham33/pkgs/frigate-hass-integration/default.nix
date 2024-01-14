{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, pytz
}:

buildHomeAssistantComponent rec {
  owner = "graham33";
  domain = "frigate";
  version = "4.0.0";
  format = "other"; # has pyproject.toml but no build system defined

  src = fetchFromGitHub {
    owner = "blakeblackshear";
    repo = "frigate-hass-integration";
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

  # TODO: default installPhase uses $src, so patches don't take effect
  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -r custom_components/ $out/
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/blakeblackshear/frigate-hass-integration";
    license = licenses.mit;
    description = "Frigate Home Assistant integration";
    maintainers = with maintainers; [ graham33 ];
  };
}
