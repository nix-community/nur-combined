{ stdenv
, fetchFromGitHub
, installShellFiles

, zsh
}:

stdenv.mkDerivation {
  pname = "zsh-z";
  version = "2020.06.30.ae71aab";

  src = fetchFromGitHub {
    owner = "agkozak";
    repo = "zsh-z";
    rev = "ae71aabec5472095b01d25b4c341adb349c277f4";
    sha256 = "1b3ad39l90jqzvfym6xl7lxsmab0anmjs7viiz8ldxddad9106b0";
  };

  nativeBuildInputs = [ installShellFiles ];

  propogatedBuildInputs = [ zsh ];

  installPhase = ''
    install -D zsh-z.plugin.zsh \
      $out/share/zsh-z/zsh-z.zsh
    installShellCompletion --zsh _zshz
  '';

  meta = {
    description = ''Jump quickly to directories that you have visited "frecently." A native ZSH port of z.sh.'';
    homepage = "https://github.com/agkozak/zsh-z";
    license = stdenv.lib.licenses.mit;
  };
}
