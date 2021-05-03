{ lib }:

with lib;

{ username
, sha256
}:

let
  keys_file = builtins.fetchurl {
    url = "http://github.com/${username}.keys";
    sha256 = sha256;
  };
in
filter (x: x != "") (splitString "\n" (builtins.readFile keys_file))
