{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "zsh-history-sync";
  version = "2018-04-11";

  src = fetchFromGitHub {
    owner = "wulfgarpro";
    repo = "history-sync";
    rev = "2c901fb2e387cdd35e246d976f9a899cd6b2defa";
    sha256 = "0ib2qrgaj9pr3s49qfh462i87dxz97jpgzs0m7rlkpjzlrjfrhcd";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm0444 $src/README.md --target-directory=$out/share/zsh/plugins/history-sync
    install -Dm0444 $src/history-sync.plugin.zsh --target-directory=$out/share/zsh/plugins/history-sync
  '';
}
