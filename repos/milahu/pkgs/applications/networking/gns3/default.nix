{ callPackage
, libsForQt5
}:

let
  mkGui = args: callPackage (import ./gui.nix (args)) {
    inherit (libsForQt5) wrapQtAppsHook;
  };

  mkServer = args: callPackage (import ./server.nix (args)) { };
in
rec {
  guiStable = mkGui {
    channel = "stable";
    version = "2.2.49";
    hash = "sha256-hvLJ4VilcgtpxHeboeSUuGAco9LEnUB8J6vy/ZPajbU=";
    gns3-server = serverStable;
  };

  guiPreview = mkGui {
    channel = "stable";
    version = "2.2.49";
    hash = "sha256-hvLJ4VilcgtpxHeboeSUuGAco9LEnUB8J6vy/ZPajbU=";
    gns3-server = serverPreview;
  };

  serverStable = mkServer {
    channel = "stable";
    version = "2.2.49";
    hash = "sha256-fI49MxA6b2kPkUihLl32a6jo8oHcEwDEjmvSVDj8/So=";
  };

  serverPreview = mkServer {
    channel = "stable";
    version = "2.2.49";
    hash = "sha256-fI49MxA6b2kPkUihLl32a6jo8oHcEwDEjmvSVDj8/So=";
  };
}
