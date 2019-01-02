{ stdenv, zsh-command-time }:

stdenv.mkDerivation rec {
  name = "zsh-theme-rkj-mod";
  src = ./.;
  phases = [ "installPhase" ];
  installPhase = ''
    install -Dm0444 $src/themes/rkj-mod.zsh-theme $out/share/zsh/themes/rkj-mod.zsh-theme
  '';
}
