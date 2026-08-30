{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}: let
  pname = "llr";
  version = "0.11.3";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "etu";
      repo = pname;
      rev = version;
      hash = "sha256-gP0RmVO1O7XsrcjfpOiwIdb3j7zJrlsXZ5ErmmWmiyQ=";
    };

    vendorHash = "sha256-WzK+2qBPm45Sfd7PWMrTeGMliWYaHqH+qB788N7OVDg=";

    ldflags = ["-X main.version=${version}"];

    meta = with lib; {
      description = "llr reads text and truncates it to the terminal width";
      homepage = "https://github.com/etu/${pname}";
      changelog = "https://github.com/etu/${pname}/releases/tag/${version}";
      license = licenses.isc;
      maintainers = [maintainers.etu];
      platforms = platforms.all;
    };
  }
