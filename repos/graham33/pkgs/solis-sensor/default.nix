{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "solis-sensor";
  version = "3.3.2";
  format = "other";

  src = fetchFromGitHub {
    owner = "hultenvp";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-uPGqK6qyglz9aIU3iV/VQbwXXsaBw4HyW7LqtP/xnMg=";
  };

  propagatedBuildInputs = [
  ];

  installPhase = ''
    mkdir -p $out
    cp -r custom_components $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/hultenvp/solis-sensor";
    license = licenses.asl20;
    description = "HomeAssistant sensor for Solis portal platform V2 and SolisCloud portal.";
    maintainers = with maintainers; [ graham33 ];
  };
}
