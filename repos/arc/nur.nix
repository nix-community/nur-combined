{ pkgs }:
  # NUR passes a dummy pkgs argument:
  # https://github.com/nix-community/NUR/blob/bbd92b3542d500362759f20fe72749800b54a010/lib/evalRepo.nix#L13
  if (builtins.tryEval pkgs).success
  then import ./default.nix { inherit pkgs; }
  else import ./static.nix
