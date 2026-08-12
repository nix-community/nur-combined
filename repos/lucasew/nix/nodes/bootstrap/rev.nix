{ self, ... }:
let
  rev = "${toString self.lastModified}-${self.inputs.nixpkgs.rev}";
in
{
  system.configurationRevision = rev;
  system.nixos.label = "lucasew:nixcfg-${rev}";
}
