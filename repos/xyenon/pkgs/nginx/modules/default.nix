{ lib, newScope }:

let
  scope =
    self:
    let
      inherit (self) callPackage;
    in
    {
      http_proxy_connect = callPackage ./http_proxy_connect.nix { };
    };
in

with lib;
pipe scope [
  (makeScope newScope)
  recurseIntoAttrs
]
