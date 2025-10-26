{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
}:

let
  pname = "connectlife-ha";
  version = "0.26.0";
  owner = "oyvindwe";
  domain = "connectlife";

  src = fetchFromGitHub {
    owner = "oyvindwe";
    repo = "connectlife-ha";
    rev = "v${version}";
    hash = "sha256-t8IlwR6a8IhTomA31Ea7pZKDd/o4kWlXk/6mKdBoJSY=";
    fetchSubmodules = true;
  };

  connectlife = home-assistant.python.pkgs.callPackage ./connectlife.nix {};
in

buildHomeAssistantComponent rec {
  inherit pname version owner domain src;

  postInstall = ''
    cp -r connectlife $out/custom_components/${domain}/
  '';

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
