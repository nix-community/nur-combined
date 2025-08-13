{
  pkgs,
  lib,
  writeShellApplication,
}:
writeShellApplication {
  name = "nix-fix-hash";

  runtimeInputs = with pkgs; [
    nix
  ];

  text = builtins.readFile ./nix-fix-hash.sh;

  meta = {
    description = "Nix hash fixer";
    mainProgram = "nix-fix-hash";
    homepage = "https://github.com/spotdemo4/nur/tree/main/pkgs/nix-fix-hash/nix-fix-hash.sh";
    platforms = lib.platforms.all;
  };
}
