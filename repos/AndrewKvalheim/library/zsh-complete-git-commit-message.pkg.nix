{ lib
, resholve

  # Dependencies
, git
, gnused
, zsh
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
resholve.writeScript "complete-git-commit-message.plugin.zsh" {
  interpreter = getExe zsh;
  inputs = [ git gnused ];
  fake.external = [
    "_describe"
    "_git"
    "_git-commit_original"
    "functions"
  ];
  execer = [ "cannot:${getExe git}" ];
} (readFile ./assets/complete-git-commit-message.plugin.zsh)
