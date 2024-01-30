{ lib, newScope }:

lib.makeScope newScope (self: with self; {
  http_proxy_connect = callPackage ./http_proxy_connect.nix { };
})
