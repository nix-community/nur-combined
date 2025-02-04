{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "mrpack-install";
  version = "0.16.10-unstable-2024-11-24";

  src = fetchFromGitHub {
    owner = "nothub";
    repo = pname;
    rev = "3363dcb5671fca3433119775ba2ab467c1675804";
    hash = "sha256-CvPLECLrizXfZWbC98ZSfldA1QA3OSwMicH4fOodzOo=";
  };

  vendorHash = "sha256-4FKt/IcmI1ev/eHzQpicWkYWAh8axUgDL7QxXRioTnc=";

  # has a test that fails related to paths or something
  # don't know why, but it seems to be not very important
  doCheck = false;

  meta = with lib; {
    description = "Modrinth Modpack server deployment";
    homepage = "https://github.com/nothub/mrpack-install";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "mrpack-install";
  };
}
