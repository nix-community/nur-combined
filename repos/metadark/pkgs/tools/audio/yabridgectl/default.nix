{ lib, rustPlatform, yabridge }:

rustPlatform.buildRustPackage rec {
  pname = "yabridgectl";
  version = yabridge.version;

  src = yabridge.src;
  sourceRoot = "source/tools/yabridgectl";
  cargoHash = "sha256-ni+gL7+sN4r2iqFSLAIU38tUui5AWoq9IFcdiKJVUOo=";

  patches = [
    ./libyabridge-from-nix-profiles.patch
  ];

  patchFlags = [ "-p3" ];

  meta = with lib; {
    description = "A small, optional utility to help set up and update yabridge for several directories at once";
    homepage = "https://github.com/robbert-vdh/yabridge/tree/master/tools/yabridgectl";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
  };
}
