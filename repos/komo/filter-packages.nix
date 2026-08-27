packages:
let
  inherit (import <nixpkgs> { }) lib;
  everyPackages = lib.listToAttrs (
    map (
      system:
      lib.listToAttrs (
        map (package: {
          name = "${package.name}-${system.name}";
          inherit (package) value;
        }) (lib.attrsToList system.value)
      )
    ) (lib.attrsToList packages)
  );
in
everyPackages
