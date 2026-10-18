{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
}:

let
  pname = "connectlife-ha";
  version = "0.52.0";
  owner = "oyvindwe";
  domain = "connectlife";

  src = fetchFromGitHub {
    owner = "oyvindwe";
    repo = "connectlife-ha";
    rev = "v${version}";
    hash = "sha256-AAOoRrUxvYSOLi3ZO4bUU+ptyE6v5kejc3j82HTGTKU=";
  };

  connectlife = home-assistant.python3Packages.callPackage ./connectlife.nix { };
in

buildHomeAssistantComponent rec {
  inherit
    pname
    version
    owner
    domain
    src
    ;

  dontBuild = true;

  dependencies = [
    connectlife
  ];

  passthru = { inherit connectlife; };

  meta = with lib; {
    description = "ConnectLife integration for Home Assistant";
    homepage = "https://github.com/oyvindwe/connectlife-ha";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ mrene ];
    platforms = platforms.all;
  };
}
