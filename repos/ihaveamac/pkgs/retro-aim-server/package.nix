{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "retro-aim-server";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "mk6i";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-M5OwiCSKagtUSTsqntq9oEMKCvZ/zXHv6Wdmz1GI+qk=";
  };

  vendorHash = "sha256-PWoohOrZC05urLWrbjnhDQiRCaWGlUHnAA2Kcgzn1z4=";

  meta = with lib; {
    description = "Self-hostable instant messaging server compatible with classic AIM and ICQ clients";
    homepage = "https://github.com/mk6i/retro-aim-server";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
