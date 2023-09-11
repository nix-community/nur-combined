{ lib, pkgs, ... }:
{
  programs.bash.promptInit = lib.mkAfter ''
    export SD_ROOT="$(dotfilesDir)/bin"
    export SD_EDITOR=$EDITOR
    export SD_CAT=cat
  '';

  environment.systemPackages = [
    pkgs.script-directory
  ];
}
