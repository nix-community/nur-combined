{ global, ... }:
{
  programs.bash.promptInit = ''
    function loadDotfilesEnv {
      ${global.environmentShell}
    }
  '';
}
