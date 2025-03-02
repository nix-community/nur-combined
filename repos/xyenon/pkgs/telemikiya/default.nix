{
  lib,
  fetchFromGitHub,
  buildGoModule,
  unstableGitUpdater,
}:

buildGoModule {
  pname = "telemikiya";
  version = "0-unstable-2025-02-26";

  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "TeleMikiya";
    rev = "6f6aca6554f9be6e0865b37758d91c007154dba6";
    hash = "sha256-CE41jsEpqNhq/SGHJCDOIALgffjq1bRjZsFLNHWIMsI=";
  };

  vendorHash = "sha256-b0XAv0Dt5K10aqJY7Qj8iNNepuYKa0/sFCR78fEIXUQ=";

  subPackages = [ "." ];
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    mainProgram = "telemikiya";
    description = "Hybrid message search tool for Telegram";
    homepage = "https://github.com/XYenon/TeleMikiya";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
  };
}
