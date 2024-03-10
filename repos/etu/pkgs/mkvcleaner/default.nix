{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}: let
  pname = "mkvcleaner";
  version = "1.0.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "etu";
      repo = pname;
      rev = version;
      hash = "sha256-5UG2u7BTrqTLCSKpD2ioI1HleCUe3woMsrjateXhJuI=";
    };

    vendorHash = "sha256-jjZ2XVvy5Qc53HJQ02KPDsmUNpsVFFaj9P/px2U01nQ=";

    meta = with lib; {
      description = "bulk-remux mkv-files from tracks of unwanted languages";
      homepage = "https://github.com/etu/${pname}";
      changelog = "https://github.com/etu/${pname}/releases/tag/${version}";
      license = licenses.isc;
      maintainers = [maintainers.etu];
      platforms = platforms.all;
    };
  }
