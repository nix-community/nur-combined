{ global, lib, ... }:
{
  programs.bash.promptInit = lib.mkBefore ''
    function loadDotfilesEnv {
      ${global.environmentShell}
    }
    export -f loadDotfilesEnv
  '';
}
