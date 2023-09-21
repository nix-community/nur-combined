{ stdenv
, lib
, fetchFromGitHub
, installShellFiles

, zsh
}:

stdenv.mkDerivation {
  pname = "zsh-z";
  version = "20210117.g289a4a7";

  src = fetchFromGitHub {
    owner = "agkozak";
    repo = "zsh-z";
    rev = "289a4a7208db9b1778cba71c58fed46dbcea3bc7";
    sha256 = "016prpavxdzjg372y2700rczdgzjb53bqz5mxjgmvrvjxwj69cf0";
  };

  nativeBuildInputs = [ installShellFiles ];

  propogatedBuildInputs = [ zsh ];

  installPhase = ''
    install -D zsh-z.plugin.zsh $out/share/zsh-z/zsh-z.zsh
    installShellCompletion --zsh _zshz
  '';

  meta = with lib; {
    description = ''Jump quickly to directories that you have visited "frecently." A native ZSH port of z.sh.'';
    homepage = "https://github.com/agkozak/zsh-z";
    license = licenses.mit;
    platforms = zsh.meta.platforms;
  };
}
