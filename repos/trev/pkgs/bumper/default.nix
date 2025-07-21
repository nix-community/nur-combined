{
  pkgs,
  lib,
  writeShellApplication,
}:
writeShellApplication {
  name = "bumper";

  runtimeInputs = with pkgs; [
    git
    nix-update
    wl-clipboard
    wl-clipboard-x11
  ];

  text = builtins.readFile ./bumper.sh;

  meta = {
    description = "Git version bumper";
    mainProgram = "bumper";
    homepage = "https://github.com/spotdemo4/nur/tree/main/pkgs/bumper/bumper.sh";
    platforms = lib.platforms.all;
  };
}
