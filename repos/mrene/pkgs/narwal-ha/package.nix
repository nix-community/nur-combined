{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
}:

let
  pname = "narwal-ha";
  version = "1.0.11";
  owner = "sjmotew";
  domain = "narwal";

  src = fetchFromGitHub {
    inherit owner;
    repo = "NarwalIntegration";
    tag = "v${version}";
    hash = "sha256-3tApVG0foVOF2jg5sQY/ERHv2e9KBE9ax9HeXbIJNZk=";
  };

  bbpb = home-assistant.python3Packages.callPackage ./bbpb.nix { };
in

buildHomeAssistantComponent {
  inherit
    pname
    version
    owner
    domain
    src
    ;

  dontBuild = true;

  dependencies = with home-assistant.python3Packages; [
    bbpb
    pillow
    websockets
  ];

  passthru = { inherit bbpb; };

  meta = with lib; {
    description = "Narwal Flow robot vacuum integration for Home Assistant";
    homepage = "https://github.com/sjmotew/NarwalIntegration";
    license = licenses.mit;
    maintainers = with maintainers; [ mrene ];
    platforms = platforms.all;
  };
}
