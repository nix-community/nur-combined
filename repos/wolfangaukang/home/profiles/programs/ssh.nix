{ lib }:

let
  inherit (lib) concatStringsSep;

in {
  programs.ssh = {
    enable = true;
    matchBlocks =
      let
        user = "marx";
        hellfireIPBase = "10.11.12";

      in {
        surtsey = {
          inherit user;
          hostname = concatStringsSep "." [ hellfireIPBase "203"];
          identityFile = ["~/.ssh/Keys/devices/surtsey"];
        };
        grimsnes = {
          inherit user;
          hostname = concatStringsSep "." [ hellfireIPBase "112"];
          identityFile = ["~/.ssh/Keys/devices/servers"];
        };
      };
  };
}
