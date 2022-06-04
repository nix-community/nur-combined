{ pkgs }: let
  # NUR passes a dummy pkgs argument:
  # https://github.com/nix-community/NUR/blob/bbd92b3542d500362759f20fe72749800b54a010/lib/evalRepo.nix#L13
  arc = if (builtins.tryEval pkgs).success
  then import ./default.nix { inherit pkgs; }
  else let
    arc = import ./default.nix { };
  in {
    inherit (arc) packages build shells lib;
  } // import ./static.nix;
in arc // {
  packages = builtins.removeAttrs arc.packages [ "rustfmt-nightly" ];
}
