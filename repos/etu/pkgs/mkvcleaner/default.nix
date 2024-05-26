{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}: let
  pname = "mkvcleaner";
  version = "1.1.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "etu";
      repo = pname;
      rev = version;
      hash = "sha256-0jVw1nneP8k0v1VSCnnQnX61o8wjtOw1QnTwnuYr5k8=";
    };

    vendorHash = "sha256-UO6qcgd39PRXSnfE8kTuyug8o7VRhnyfTjLGVWGYxfc=";

    meta = with lib; {
      description = "bulk-remux mkv-files from tracks of unwanted languages";
      homepage = "https://github.com/etu/${pname}";
      changelog = "https://github.com/etu/${pname}/releases/tag/${version}";
      license = licenses.gpl3Plus;
      maintainers = [maintainers.etu];
      platforms = platforms.all;
    };
  }
