{ lib
, fetchFromGitHub
, bump2version
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "miele";
  version = "0.1.14";
  format = "other";

  src = fetchFromGitHub {
    owner = "astrandb";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Ybh8vgCge8SfoGK9qQ1pYRMFqI6Xz9yGsvK2PsyaDgs=";
  };

  nativeBuildInputs = [
    bump2version
  ];

  propagatedBuildInputs = [
    colorlog
    flatdict
    pymiele
  ];

  installPhase = ''
    mkdir -p $out
    cp -r custom_components $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/astrandb/miele";
    description = "Miele Integration for Home Assistant";
    license = licenses.mit;
    maintainers = with maintainers; [ graham33 ];
  };
}
