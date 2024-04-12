{ inputs
, localLib
, hostname
, ...
}:

let
  inherit (localLib) importSystemUsers;

in
{
  imports = [
    ./configuration.nix

    "${inputs.self}/system/profiles/base.nix"
  ] ++ importSystemUsers [ "root" ] hostname;
}
