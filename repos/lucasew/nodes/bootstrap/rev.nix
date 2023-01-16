{pkgs, self, ...}: let
  rev = if (self ? rev) then 
      builtins.trace "detected flake hash: ${self.rev}" self.rev
    else
      builtins.trace "flake hash not detected!" null
  ;
in {
  system.configurationRevision = rev;
  system.nixos.label = "lucasew:nixcfg-${rev}";
}

