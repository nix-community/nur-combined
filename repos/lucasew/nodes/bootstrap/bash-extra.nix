{ global, self, ... }:
{
  programs.bash.promptInit = ''
    function loadDotfilesEnv {
      ${global.environmentShell}
    }
  '';
}
