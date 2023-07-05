{ global, self, ... }:
{
  programs.bash.promptInit = ''
    function loadDotfilesEnv {
      ${global.environmentShell}
    }
    function loadBinEnv {
      export PATH="$PATH:${../../../bin}"
    }
  '';
}
