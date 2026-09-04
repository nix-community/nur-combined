{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}: let
  pname = "mkvcleaner";
  version = "1.2.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "etu";
      repo = pname;
      rev = version;
      hash = "sha256-B3+NhxSDlDujC97GgqJjQdY4bl4/+iFqyNO63LkuLyg=";
    };

    vendorHash = "sha256-UO6qcgd39PRXSnfE8kTuyug8o7VRhnyfTjLGVWGYxfc=";

    ldflags = ["-X main.version=${version}"];

    meta = with lib; {
      description = "bulk-remux mkv-files from tracks of unwanted languages";
      homepage = "https://github.com/etu/${pname}";
      changelog = "https://github.com/etu/${pname}/releases/tag/${version}";
      license = licenses.gpl3Plus;
      maintainers = [maintainers.etu];
      platforms = platforms.all;
    };
  }
