{pkgs, ...}: 
let
  bin = pkgs.writeShellScript "nixgram-service" ''
    echo "Iniciando..."
    ${pkgs.dotenv}/bin/dotenv @${builtins.toString ../../secrets/nixgram.env} -- ${pkgs.nixgram}/bin/nixgram
  '';
  systemdUserService = import <dotfiles/lib/systemdUserService.nix>;
in systemdUserService {
  description = "Command bot for telegram";
  command = "${bin}";
}
