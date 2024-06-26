{ pkgs
, lib
, ...
}:

let
  inherit (pkgs) lldb;
  inherit (pkgs.stdenv) isDarwin;

in {
  packages = [
    lldb
  ] ++ lib.optionals isDarwin ( with pkgs.darwin; [
    apple_sdk.frameworks.Security
    apple_sdk.frameworks.CoreFoundation
    libiconv
  ]);

  languages = {
    nix.enable = true;
    rust.enable = true;
  };
}
