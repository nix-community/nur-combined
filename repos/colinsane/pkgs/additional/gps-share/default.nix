{ lib
, fetchFromGitHub
, pkg-config
, rustPlatform
, udev
}:

rustPlatform.buildRustPackage rec {
  pname = "gps-share";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "zeenix";
    repo = "gps-share";
    rev = version;
    hash = "sha256-Rh7Pt9JN30TyuxwHOn8dwZrUfmkknUhOGonbhROpGxA=";
  };

  cargoHash = "sha256-8txHiK+aBh4hO66VQWTH/7li62O74xMqCg+sBFZ6KKU=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    udev
  ];

  doCheck = false;  #< 'Failed to start gps-share: Os { code: 2, kind: NotFound, message: "No such file or directory" }'

  meta = with lib; {
    description = "utility to share your GPS device on local network";
    homepage = "https://github.com/zeenix/gps-share";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ colinsane ];
  };
}
