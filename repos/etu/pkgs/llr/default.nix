{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}: let
  pname = "llr";
  version = "0.10.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "etu";
      repo = pname;
      rev = version;
      hash = "sha256-Ab8JCaJw90wWGTB5y/NXkQvbGGknQRHmyMc0Lei2aMI=";
    };

    vendorHash = "sha256-25a2WMXvabxUelm0OKVAN+YQ5WKb05Euq+ubWdvaXgQ=";

    meta = with lib; {
      description = "llr reads text and truncates it to the terminal width";
      homepage = "https://github.com/etu/${pname}";
      changelog = "https://github.com/etu/${pname}/releases/tag/${version}";
      license = licenses.isc;
      maintainers = [maintainers.etu];
      platforms = platforms.all;
    };
  }
