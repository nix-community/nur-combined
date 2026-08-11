{ callPackage
, deno
}:

deno // rec {

  # pkgs.deno.pkgs is not used
  # nix-repl> :l <nixpkgs> 
  # nix-repl> pkgs.deno.pkgs
  # error: attribute 'pkgs' missing

  pkgs = callPackage ./pkgs {};

}
