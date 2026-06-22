{
  pkgs,
  lib,
  ...
}:
pkgs.runCommand "zellij-wrappers"
  {
    nativeBuildInputs = [ pkgs.makeWrapper ];
    meta.description = "zellij with specific shells";
  }
  ''
    mkdir -p $out/bin

    ${lib.concatMapStringsSep "\n"
      (shell: ''
        makeWrapper ${lib.getExe pkgs.zellij} $out/bin/zellij-${pkgs.${shell}.meta.mainProgram} \
          --add-flags "options --default-shell ${lib.getExe pkgs.${shell}} --session-name ${pkgs.${shell}.meta.mainProgram} --attach-to-session true"
      '')
      [
        "bashInteractive"
        "fish"
        "ion"
        "nushell"
        "powershell"
        "zsh"
      ]
    }
  ''
