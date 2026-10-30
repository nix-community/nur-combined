{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "retro-aim-server";
  version = "0.25.0";

  src = fetchFromGitHub {
    owner = "mk6i";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-V2dzXfLcjyAaTlXmAq5hEfM62JDLcvBnr/ACZJfRt+E=";
  };

  vendorHash = "sha256-klqzwshmJqCOfE+W05ga6dbCHaIGhP7X4OnTSo8+9rQ=";

  meta = with lib; {
    description = "Self-hostable instant messaging server compatible with classic AIM and ICQ clients";
    homepage = "https://github.com/mk6i/retro-aim-server";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
