{ lib
, python3Packages
, fetchFromGitHub
, nix-update-script
}:
python3Packages.buildPythonApplication rec {
  pname = "hoyolab-daily-bot";
  version = "1.1";

  src = fetchFromGitHub {
    repo = "hoyolab-daily-bot";
    owner = "AtaraxiaSjel";
    rev = "v${version}";
    hash = "sha256-NJZf/UxgAdMnIkEkkRWqnraBpI4ifnjvU4mYYKVGqb0=";
  };

  propagatedBuildInputs = with python3Packages; [
    requests
    browser-cookie3
    tzdata
    typing-extensions
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Honkai: Star Rail's Hoyolab Daily Check-in Bot";
    homepage = "https://github.com/AtaraxiaSjel/hoyolab-daily-bot";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
