{
  default = final: prev: let
    reserved = ["lib" "overlays" "nixosModules" "homeModules" "darwinModules" "flakeModules"];
    nurAttrs = import ../default.nix {pkgs = prev;};
  in
    builtins.removeAttrs nurAttrs reserved;
}
