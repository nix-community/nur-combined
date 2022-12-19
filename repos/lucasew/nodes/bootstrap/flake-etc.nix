{self, lib, config, ...}:
let
  inherit (builtins) length attrNames head tail concatStringsSep;
    inputNames = attrNames self.inputs;
in {
  environment.etc = let
    recur = inputs: if
      length inputs == 0 then {} 
    else 
      ({ "flake/${head inputs}" = { source = self.inputs."${head inputs}".outPath; }; } // (recur (tail inputs)));
    in recur inputNames;

  nix.nixPath = lib.mkOverride 0 ((map (k: "${k}=/etc/flake/${k}") inputNames) ++ ["dotfiles=~/.dotfiles"]);
}
