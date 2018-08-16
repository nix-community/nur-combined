{ stdenv, zsh-command-time }:

stdenv.mkDerivation rec {
  name = "oh-my-zsh-custom";
  src = ./.;
  phases = [ "installPhase" ];
  installPhase = ''
    install -Dm444 ${zsh-command-time}/share/zsh-command-time/command-time.plugin.zsh --target-directory=$out/plugins/command-time
    install -Dm444 $src/themes/rkj-mod.zsh-theme --target-directory=$out/themes
  '';
}