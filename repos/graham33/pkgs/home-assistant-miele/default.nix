{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "home-assistant-miele";
  version = "0.9.3";
  format = "other";

  src = fetchFromGitHub {
    owner = "HomeAssistant-Mods";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-f079jzTDvnqwdOMvCI0z8FvURA9N6QLc4GpNtL+vmro=";
  };

  propagatedBuildInputs = [
    requests-oauthlib
  ];

  installPhase = ''
    mkdir -p $out
    cp -r custom_components $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/HomeAssistant-Mods/home-assistant-miele";
    description = "Exposes Miele state information of appliances connected to a Miele user account.";
    maintainers = with maintainers; [ graham33 ];
  };
}
