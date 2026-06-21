{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
}:

let
  pname = "narwal-ha";
  version = "1.0.0-unstable-2026-05-30";
  owner = "sjmotew";
  domain = "narwal";

  src = fetchFromGitHub {
    inherit owner;
    repo = "NarwalIntegration";
    rev = "125d0a3a3409a1109e26ed8c71f204a14b381f60";
    hash = "sha256-SxU4YAiBfc4oKmRDsMsgP49DsHGxrove4fSK8URxpv8=";
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
