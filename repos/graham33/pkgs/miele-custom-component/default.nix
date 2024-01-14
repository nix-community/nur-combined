{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, bump2version
, colorlog
, flatdict
, pymiele
}:

buildHomeAssistantComponent rec {
  owner = "graham33";
  domain = "miele";
  version = "0.1.17";
  format = "other";

  src = fetchFromGitHub {
    owner = "astrandb";
    repo = domain;
    rev = "v${version}";
    sha256 = "sha256-h9ga7VqHfACTCiy/tCppn3WvMYf4WazLQxYHFb5XUrE=";
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
