let
  inherit (builtins) toString hasAttr;
in
if (hasAttr "getFlake" builtins) then
  let
    flake = builtins.getFlake "${builtins.toString ../.}";
  in
  [
    (import ../overlay.nix flake)
  ] else [ ]
