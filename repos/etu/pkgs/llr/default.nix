{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}: let
  pname = "llr";
  version = "0.11.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "etu";
      repo = pname;
      rev = version;
      hash = "sha256-e28oY6AcUl+24xDDR7w1dPiNpDVWHpTdT753fZ0lXAw=";
    };

    vendorHash = "sha256-25a2WMXvabxUelm0OKVAN+YQ5WKb05Euq+ubWdvaXgQ=";

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
