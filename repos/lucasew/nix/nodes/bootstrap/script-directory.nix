{ lib, pkgs, ... }:
{
  programs.bash.promptInit = lib.mkAfter ''
    export SD_ROOT="$(${../../../bin/d/root})/bin"
    export SD_EDITOR=$EDITOR
    export SD_CAT=cat
  '';

  environment.systemPackages = [ pkgs.script-directory ];
}
